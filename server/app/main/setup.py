from flask import Flask, render_template, request, session
from flask_socketio import Namespace, send, emit, join_room, leave_room
from .. import socketio
import settings
import time
import gpxpy.geo

queued_games = {}
games = {}

def get_coord_delta(lat1, long1, lat2, long2):
	return gpxpy.geo.haversine_distance(lat1, lon1, lat2, lon2) # meters

def is_in_region(lat1, long1, lat2, long2):
	if abs(lat1 - lat2) < .005 and abs(long2 - long2) < .005:
		return True
	return False

def is_rejoining_game(udid):
	for game_id in games:
		if queued_games[game_id]['state'] == 3:
			for player_udid in queued_games[game_id]['players']:
				if udid == player_udid:
					return game_id
	return False

def register_user(user_name, is_offense, udid, sid, latitude, longitude):
	print("queued games:")
	print(queued_games)
	for game_id in queued_games:
		print('joining existing queued game')
		pass
		if (abs(latitude - queued_games[game_id]['latitude']) < .005 
			and abs(longitude - queued_games[game_id]['longitude']) < .005):
			print("joining existing game")
			queued_games[game_id]['players'][udid] = {
				'sid': sid,
				'user_name': user_name,
				'is_offense': is_offense,
				'joined': False,
				'latitude': latitude,
				'longitude': longitude,
			}
			return game_id
	new_game_id = str(int(time.time())) + '-' + udid[-12:]
	queued_games[new_game_id] = {
		'players': {
			udid: {
				'sid': sid,
				'user_name': user_name,
				'is_offense': is_offense,
				'joined': False,
				'latitude': latitude,
				'longitude': longitude,
			}
		},
		'latitude': latitude,
		'longitude': longitude,
		'state': 0,
		'start_time': -1,
		'config': {},
		'items_enabled': False,
	}
	return new_game_id

@socketio.on('enterQueue')
def handle_message(user_name, is_offense, udid, latitude, longitude):
	print('connect user ' + str(user_name) + ' ' + str(is_offense) + ' ' + str(latitude) + ' ' + str(longitude) + ' ' + str(udid))
	rejoining_game_id = is_rejoining_game(udid)
	if rejoining_game_id:
		join_room(rejoining_game_id)
		print('rejoining game')
		return 'rejoining', rejoining_game_id
	game_id = register_user(user_name, is_offense, udid, request.sid, latitude, longitude)
	join_room(game_id)
	return 'not_rejoining', game_id

@socketio.on('leaveQueuedGame')
def handle_message(game_id, udid):
	del queued_games[game_id]['players'][udid]
	print(udid, ' left game ', game_id)
	emit('updateWaitingUsers', queued_games[game_id]['players'], room=game_id, broadcast=True)

@socketio.on('getWaitingUsers')
def handle_message(game_id, just_joined=False):
    if just_joined:
    	emit('updateWaitingUsers',
    		(
    			queued_games[game_id]['players'],
    			queued_games[game_id]['state']
    		),
    		room=game_id,
    		broadcast=True
    	)
    else:
    	emit('updateWaitingUsers',
    		(
    			queued_games[game_id]['players'],
    			queued_games[game_id]['state']
    		)
    	)

@socketio.on('switchTeams')
def handle_message(game_id, udid):
    is_offense = queued_games[game_id]['players'][udid]['is_offense'] 
    queued_games[game_id]['players'][udid]['is_offense'] = not is_offense
    emit('updateWaitingUsers',
    	(
	    	queued_games[game_id]['players'],
	    	queued_games[game_id]['state']
	    ),
    	room=game_id,
    	broadcast=True
    )

@socketio.on('createGame')
def handle_message(game_id, udid):
	if queued_games[game_id]['state'] == 0:
		queued_games[game_id]['state'] = 1
		emit('updateWaitingUsers',
			(
		    	queued_games[game_id]['players'],
		    	queued_games[game_id]['state']
		    ),
	    	room=game_id,
	    	broadcast=True
    	)
		return True
	return False

@socketio.on('stopCreatingGame')
def handle_message(game_id, udid):
	if queued_games[game_id]['state'] == 1:
		queued_games[game_id]['state'] = 0
		emit('updateWaitingUsers',
			(
		    	queued_games[game_id]['players'],
		    	queued_games[game_id]['state']
		    ),
	    	room=game_id,
	    	broadcast=True
    	)
		return True
	return False

@socketio.on('joinGame')
def handle_message(game_id, udid):
	if queued_games[game_id]['state'] == 2:
		queued_games[game_id]['players'][udid]['joined'] = True
		if queued_games[game_id]['start_time'] == -1:
			all_joined = True
			for player_udid in queued_games[game_id]['players']:
				if queued_games[game_id]['players'][player_udid]['joined'] == False:
					all_joined = False
					break
			if all_joined == True:
				queued_games[game_id]['state'] = 3
				queued_games[game_id]['start_time'] = time.time() + 3
			emit('updateGameDidStart',
				(
			    	queued_games[game_id]['players'],
			    	queued_games[game_id]['state'],
			    	queued_games[game_id]['start_time'],
			    ),
		    	room=game_id,
		    	broadcast=True
    	)
    	return True
	return False

@socketio.on('getGameConfig')
def handle_message(game_id):
	return queued_games[game_id]['config'], queued_games[game_id]['players']

@socketio.on('postGameOptions')
def handle_message(game_id, tag_sensitivity, game_length, capture_time, items_enabled, test_mode_enabled):
	queued_games[game_id]['config']['tag_sensitivity'] = tag_sensitivity
	queued_games[game_id]['config']['game_length'] = game_length
	queued_games[game_id]['config']['capture_time'] = capture_time
	queued_games[game_id]['config']['items_enabled'] = items_enabled
	queued_games[game_id]['config']['test_mode_enabled'] = test_mode_enabled
	if items_enabled == False:
		queued_games[game_id]['state'] = 2
	return True

@socketio.on('postItemOptions')
def handle_message(
		game_id,
		offense_starting_funds,
		defense_starting_funds,
		item_abundance_offense,
		item_abundance_defense,
		item_prices_offense,
		item_prices_defense,
		items_disabled_offense,
		items_disabled_defense,
		item_mode_on
	):
	queued_games[game_id]['config']['items_enabled'] = True
	queued_games[game_id]['config']['offense_starting_funds'] = offense_starting_funds
	queued_games[game_id]['config']['defense_starting_funds'] = defense_starting_funds
	queued_games[game_id]['config']['item_abundance_offense'] = item_abundance_offense
	queued_games[game_id]['config']['item_abundance_defense'] = item_abundance_defense
	queued_games[game_id]['config']['item_prices_offense'] = item_prices_offense
	queued_games[game_id]['config']['item_prices_defense'] = item_prices_defense
	queued_games[game_id]['config']['items_disabled_offense'] = items_disabled_offense
	queued_games[game_id]['config']['items_disabled_defense'] = items_disabled_defense
	queued_games[game_id]['config']['item_mode_on'] = item_mode_on
	return True

@socketio.on('postPointLocation')
def handle_message(
		game_id,
		point_lat,
		point_lon,
		point_radius,
		base_lat,
		base_lon,
		base_radius
	):
	games[game_id] = {
		'players': {},
		'other': {
			'capture_state': 0,
			'capturer': 0,
		},
	}
	queued_games[game_id]['config']['point_lat'] = point_lat
	queued_games[game_id]['config']['point_lon'] = point_lon
	queued_games[game_id]['config']['point_radius'] = point_radius
	queued_games[game_id]['config']['base_lat'] = base_lat
	queued_games[game_id]['config']['base_lon'] = base_lon
	queued_games[game_id]['config']['base_radius'] = base_radius
	queued_games[game_id]['state'] = 2
	offense_pos_inc = 0
	defense_pos_inc = 0
	for player in queued_games[game_id]['players']:
		player_dict = queued_games[game_id]['players'][player]
		if player_dict['is_offense'] == True:
			position = 'o' + str(offense_pos_inc)
			offense_pos_inc +=1
		else:
			position = 'd' + str(defense_pos_inc)
			defense_pos_inc +=1
		queued_games[game_id]['players'][player]['position'] = position
		games[game_id]['players'][position] = {
			'is_offense': True,
			'status': 2,
			'latitude': player_dict['latitude'],
			'longitude': player_dict['longitude'],
			'capturing': 0,
		}
	return True

@socketio.on('getDidGameStart')
def handle_message(game_id):
	emit('updateDidGameStart', queued_games[game_id]['start_time'], room=game_id, broadcast=True)


@socketio.on('getDidGameStart')
def handle_message(game_id):
	emit('updateDidGameStart', queued_games[game_id]['start_time'])

@socketio.on('updateGameState')
def handle_message(
		game_id,
		position,
		status,
		latitude,
		longitude,
	):
	print("game state updated")
	print(position, " ", latitude)
	games[game_id][position]['status'] = status
	games[game_id][position]['latitude'] = latitude
	games[game_id][position]['longitude'] = longitude
	print("returning ", games[game_id]['players'], " ", games[game_id]['other'])
	return games[game_id]['players'], games[game_id]['other']

@socketio.on('getPosition')
def handle_message(game_id, udid):
	games[game_id][position]['status'] = status
	games[game_id][position]['latitude'] = latitude
	games[game_id][position]['longitude'] = longitude
	games[game_id][position]['capturing'] = capturing
	return games[game_id]

@socketio.on('postGameEvent')
def handle_message(game_event, game_id):
	print("game event")
	print(game_event)
	emit('sendGameEvent', game_event, room=game_id, broadcast=True)
	return True
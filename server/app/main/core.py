from flask import Flask, render_template, request, session
from flask_socketio import Namespace, send, emit, join_room, leave_room
from .. import socketio
import time
import threading

games = {}

def is_rejoining_game(udid):
	for game_id in games:
		for player_udid in games[game_id]['players_udid']:
			if udid == player_udid:
				return game_id
	return False

def register_user(user_name, is_offense, udid, sid, latitude, longitude):
	print("player connected: ", user_name)
	for game_id in games:
		if (abs(latitude - games[game_id]['latitude']) < .005 
			and abs(longitude - games[game_id]['longitude']) < .005):
			print("joining existing game")
			games[game_id]['players_udid'][udid] = {
				'sid': sid,
				'user_name': user_name,
				'is_offense': is_offense,
				'joined': False,
				'latitude': latitude,
				'longitude': longitude,
			}
			return game_id
	new_game_id = str(int(time.time())) + '-' + udid[-12:]
	games[new_game_id] = {
		'players_udid': {
			udid: {
				'sid': sid,
				'user_name': user_name,
				'is_offense': is_offense,
				'joined': False,
				'latitude': latitude,
				'longitude': longitude,
			}
		},
		'players_pos': {},
		'latitude': latitude,
		'longitude': longitude,
		'state': 0,
		'start_time': -1,
		'config': {},
		'items_enabled': False,
		'heartbeat': int(time.time()),
		'point_state': {
			'capture_state': '',
			'capturer': '',
			'heartbeat': 0,
		}
	}
	return new_game_id

@socketio.on('enterQueue')
def handle_message(user_name, is_offense, udid, latitude, longitude):
	rejoining_game_id = is_rejoining_game(udid)
	if rejoining_game_id:
		join_room(rejoining_game_id)
		current_timer_count = int(5 + games[rejoining_game_id]['config']['game_length'] \
			- (int(time.time()) - games[rejoining_game_id]['start_time']))
		return 'rejoining', rejoining_game_id, games[rejoining_game_id]['config'], \
			games[rejoining_game_id]['players_pos'], current_timer_count
	game_id = register_user(user_name, is_offense, udid, request.sid, latitude, longitude)
	join_room(game_id)
	return 'not_rejoining', game_id

@socketio.on('leaveGame')
def handle_message(game_id, udid):
	del games[game_id]['players_udid'][udid]
	emit('updateWaitingUsers', games[game_id]['players_udid'], room=game_id, broadcast=True)

@socketio.on('postHeartbeat')
def handle_message(game_id):
	games[game_id]['heartbeat'] = int(time.time())

@socketio.on('getWaitingUsers')
def handle_message(game_id, just_joined=False):
	games[game_id]['heartbeat'] = int(time.time())
	if just_joined:
		emit('updateWaitingUsers',
    		(
    			games[game_id]['players_udid'],
    			games[game_id]['state']
    		),
    		room=game_id,
    		broadcast=True
    	)
	else:
		emit('updateWaitingUsers',
    		(
    			games[game_id]['players_udid'],
    			games[game_id]['state']
    		)
    	)

@socketio.on('switchTeams')
def handle_message(game_id, udid):
    is_offense = games[game_id]['players_udid'][udid]['is_offense'] 
    games[game_id]['players_udid'][udid]['is_offense'] = not is_offense
    emit('updateWaitingUsers',
    	(
	    	games[game_id]['players_udid'],
	    	games[game_id]['state']
	    ),
    	room=game_id,
    	broadcast=True
    )
    return True

@socketio.on('createGame')
def handle_message(game_id, udid):
	if games[game_id]['state'] == 0:
		games[game_id]['state'] = 1
		emit('updateWaitingUsers',
			(
		    	games[game_id]['players_udid'],
		    	games[game_id]['state']
		    ),
	    	room=game_id,
	    	broadcast=True
    	)
		return True
	return False

@socketio.on('stopCreatingGame')
def handle_message(game_id, udid):
	if games[game_id]['state'] == 1:
		games[game_id]['state'] = 0
		emit('updateWaitingUsers',
			(
		    	games[game_id]['players_udid'],
		    	games[game_id]['state']
		    ),
	    	room=game_id,
	    	broadcast=True
    	)
		return True
	return False

@socketio.on('joinGame')
def handle_message(game_id, udid):
	if games[game_id]['state'] == 2:
		games[game_id]['players_udid'][udid]['joined'] = True
		if games[game_id]['start_time'] == -1:
			all_joined = True
			for player_udid in games[game_id]['players_udid']:
				if games[game_id]['players_udid'][player_udid]['joined'] == False:
					all_joined = False
					break
			if all_joined == True:
				games[game_id]['state'] = 3
				games[game_id]['start_time'] = int(time.time()) + 3
			emit('updateGameDidStart',
				(
			    	games[game_id]['players_udid'],
			    	games[game_id]['state'],
			    	games[game_id]['start_time'],
			    ),
		    	room=game_id,
		    	broadcast=True
    	)
		return True
	return False

@socketio.on('getGameConfig')
def handle_message(game_id):
	return games[game_id]['config'], games[game_id]['players_pos']

@socketio.on('postGameOptions')
def handle_message(game_id, tag_sensitivity, game_length, capture_time, items_enabled, test_mode_enabled):
	games[game_id]['config']['tag_sensitivity'] = tag_sensitivity
	games[game_id]['config']['game_length'] = game_length
	games[game_id]['config']['capture_time'] = capture_time
	games[game_id]['config']['items_enabled'] = items_enabled
	games[game_id]['config']['test_mode_enabled'] = test_mode_enabled
	if items_enabled == False:
		games[game_id]['state'] = 2
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
	games[game_id]['config']['items_enabled'] = True
	games[game_id]['config']['offense_starting_funds'] = offense_starting_funds
	games[game_id]['config']['defense_starting_funds'] = defense_starting_funds
	games[game_id]['config']['item_abundance_offense'] = item_abundance_offense
	games[game_id]['config']['item_abundance_defense'] = item_abundance_defense
	games[game_id]['config']['item_prices_offense'] = item_prices_offense
	games[game_id]['config']['item_prices_defense'] = item_prices_defense
	games[game_id]['config']['items_disabled_offense'] = items_disabled_offense
	games[game_id]['config']['items_disabled_defense'] = items_disabled_defense
	games[game_id]['config']['item_mode_on'] = item_mode_on
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
	games[game_id]['config']['point_lat'] = point_lat
	games[game_id]['config']['point_lon'] = point_lon
	games[game_id]['config']['point_radius'] = point_radius
	games[game_id]['config']['base_lat'] = base_lat
	games[game_id]['config']['base_lon'] = base_lon
	games[game_id]['config']['base_radius'] = base_radius
	games[game_id]['state'] = 2
	offense_pos_inc = 1
	defense_pos_inc = 1
	players_udid_dict = games[game_id]['players_udid']
	for player_udid in players_udid_dict:
		if players_udid_dict[player_udid]['is_offense'] == True:
			position = 'offense' + str(offense_pos_inc)
			offense_pos_inc +=1
		else:
			position = 'defense' + str(defense_pos_inc)
			defense_pos_inc +=1
		games[game_id]['players_udid'][player_udid]['position'] = position
		games[game_id]['players_pos'][position] = {
			'udid': player_udid,
			'user_name': players_udid_dict[player_udid]['user_name'],
			'is_offense': players_udid_dict[player_udid]['is_offense'],
			'status': 2,
			'latitude': players_udid_dict[player_udid]['latitude'],
			'longitude': players_udid_dict[player_udid]['longitude'],
			'capturing': 0,
		}
	return True

@socketio.on('getDidGameStart')
def handle_message(game_id):
	emit('updateDidGameStart', games[game_id]['start_time'], room=game_id, broadcast=True)

@socketio.on('getDidGameStart')
def handle_message(game_id):
	games[game_id]['heartbeat'] = int(time.time())
	emit('updateDidGameStart', games[game_id]['start_time'])

@socketio.on('updateGameState')
def handle_message(
		game_id,
		position,
		status,
		latitude,
		longitude,
	):
	position = str(position)
	game_id = str(game_id)
	games[game_id]['players_pos'][position]['status'] = status
	games[game_id]['players_pos'][position]['latitude'] = latitude
	games[game_id]['players_pos'][position]['longitude'] = longitude
	games[game_id]['heartbeat'] = int(time.time())
	return games[game_id]['players_pos'], games[game_id]['point_state']

@socketio.on('postGameEvent')
def handle_message(
		game_id,
		sender,
		event_name,
		recipient,
		latitude,
		longitude,
		extra
	):
	print("game event: ", "sender: ", sender, " event: ", event_name)
	if (
		event_name == 'tag' and games[game_id]['point_state']['capturer'] == sender
		or ( 
			event_name in ('mine_tag', 'bomb', 'sickle')
			and games[game_id]['point_state']['capturer'] == recipient
		)
		or event_name == 'lightning'
	):
		games[game_id]['point_state']['capture_state'] = ''
		games[game_id]['point_state']['capturer'] = ''
	if event_name == 'capturing':
		if games[game_id]['point_state']['capturer'] != '':
			return False
		games[game_id]['point_state']['capture_state'] = 'capturing'
		games[game_id]['point_state']['capturer'] = sender
		games[game_id]['point_state']['heartbeat'] = int(time.time())
	elif event_name == 'stopCapturing' and games[game_id]['point_state']['capturer'] == sender:
		games[game_id]['point_state']['capture_state'] = ''
		games[game_id]['point_state']['capturer'] = ''
	elif event_name == 'capture':
		if games[game_id]['point_state']['capturer'] != sender and games[game_id]['point_state']['capture_state'] != 'capturing':
			return False
		games[game_id]['point_state']['capture_state'] = 'captured'
		games[game_id]['point_state']['capturer'] = sender
		games[game_id]['point_state']['heartbeat'] = int(time.time())
	game_event = {
		'sender': sender,
		'eventName': event_name,
		'recipient': recipient,
		'latitude': latitude,
		'longitude': longitude,
		'extra': extra
	}
	emit('sendGameEvent', game_event, room=game_id, broadcast=True)
	return True

@socketio.on('postCaptureHeartbeat')
def handle_message(game_id, position):
	if games[game_id]['point_state']['capturer'] == position:
		games[game_id]['point_state']['heartbeat'] = int(time.time())

def timedLoop():
	print("timed loop fired, active GAMES: ")
	del_games = []
	for game_id in games:
		print('  ' + game_id)
		with open('nflux_log.txt', 'a+') as f:
			f.write(str(game_id) + '\t' + str(games[game_id]) + '\n')
		idle_time = int(time.time()) - games[game_id]['heartbeat']
		if idle_time > 20:
			print("Deleting inactive game ", game_id)
			del_games.append(game_id)
		# reset point cap state if capturer is inactive 
		if games[game_id]['point_state']['capture_state'] != '':
			capture_idle_time = int(time.time()) - games[game_id]['point_state']['heartbeat']
			if capture_idle_time > 15:
				print("Reseting point cap state for game: ", game_id)
				games[game_id]['point_state']['capture_state'] = ''
				games[game_id]['point_state']['capturer'] = ''
	for game_id in del_games:
		del games[game_id]
	threading.Timer(10, timedLoop).start()

timedLoop()
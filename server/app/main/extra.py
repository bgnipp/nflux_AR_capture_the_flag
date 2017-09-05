from flask import Flask, render_template, request, session
from flask_socketio import SocketIO, Namespace, send, emit, join_room, leave_room
from .. import socketio 
import time

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
"use strict";


var app = new Vue({
    el: '#app',
    data: {
        streamers: [],
    }
});

function setUserDataProto(index) {
    return function(data) {
        if (data.error !== undefined) {
            app.streamers[index].message = data.message;
            app.streamers[index].status = 'nonexistant';
            return;
        }
        if (data.logo !== undefined) {
            app.streamers[index].img = data.logo;
        }
    }
}

function setStreamDataProto(index) {
    return function(data) {
        if (data.stream === null) {
            if (app.streamers[index].status !== 'nonexistant')
                app.streamers[index].status = 'offline';
        } else {
            app.streamers[index].status = 'online';
            app.streamers[index].message = data.stream.channel.game;
            app.streamers[index].url = data.stream.channel.url;
        }
    }
}

function pushDefault(name) {
    var temp = {
        name: name,
        img: 'http://www.placehold.it/50x50',
        message: 'Offline',
        status: 'offline',
        url: 'http://www.twitch.tv/' + name,
    };
    app.streamers.push(temp);
}

function ajax(request) {
    var script = document.createElement('script');
    script.src = request.url + "?callback=" + request.callback;
    document.head.appendChild(script);
}

function getStreamerData(name, userFunc, streamFunc) {
    pushDefault(name);
    ajax({
        url: 'https://wind-bow.gomix.me/twitch-api/users/' + name,
        callback: userFunc
    });
    ajax({
        url: 'https://wind-bow.gomix.me/twitch-api/streams/' + name,
        callback: streamFunc
    });
}

var streamers = ["ESL_SC2", "OgamingSC2", "cretetion", "freecodecamp", "storbeck", "habathcx", "RobotCaleb", "noobs2ninjas", "brunofin"];
var setUserData = [];
var setStreamData = [];
for (var i in streamers) {
    setUserData[i] = setUserDataProto(i);
    setStreamData[i] = setStreamDataProto(i);
    var userFunc = 'setUserData[' + i + ']';
    var streamFunc = 'setStreamData[' + i + ']';
    getStreamerData(streamers[i], userFunc, streamFunc);
}

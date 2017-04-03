var status = {
    offline: 'offline',
    online: 'online',
}

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
            app.streamers[index].status = status.offline;
        } else {
            app.streamers[index].status = status.online;
            app.streamers[index].message = data.stream.game;
        }
    }
}

function pushDefault(name) {
    app.streamers.push({
        name: name,
        img: 'http://www.placehold.it/50x50',
        message: 'Offline',
        status: status.offline,
    });
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

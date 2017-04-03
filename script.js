var app = new Vue({
    el: '#app',
    data: {
        streamers: [
        {name: 'cookie', img: 'http://www.placehold.it/50x50', message: 'offline', status: 'offline'},
        {name: 'pie', img: 'http://www.placehold.it/50x50', message: 'Streaming cats', status: 'online'},
        {name: 'cake', img: 'http://www.placehold.it/50x50', message: 'offline', status: 'offline'},
        ],
    }
});

// function setData(data) {
//     data = Json.parse(data);
//     data['']
// }

function getStreamerData(name) {
    ajax({
        url: 'https://wind-bow.gomix.me/twitch-api/users/$name',
        callBack: setData
    });
    ajax({
        url: 'https://wind-bow.gomix.me/twitch-api/streams/$name',
        callBack: setData
    });
}

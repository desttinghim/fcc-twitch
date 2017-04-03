import mithril.M;
import js.Browser;
import promhx.Promise;
import promhx.Deferred;

@:expose
class Main {
    static var twitch:Twitch;
    static var streamers = ["ESL_SC2", "OgamingSC2", "cretetion", "freecodecamp", "storbeck", "habathcx", "RobotCaleb", "noobs2ninjas"];
    public static var users : Map<String, Deferred<User>>;
    public static var streams : Map<String, Deferred<Stream>>;
    static function main() {
        twitch = new Twitch(streamers);
        M.mount(js.Browser.document.body, twitch);

        for (streamer in streamers) {
            var a = new StreamerView({
                name: streamer,
                url: "#",
                status: 'Offline',
                img: "#",
            });
            var d1 = new Deferred<User>(); users.set(streamer, d1);
            var d2 = new Deferred<Stream>(); streams.set(streamer, d2);
            var pUser = new Promise<User>(d1);
            var pStream = new Promise<Stream>(d2);
            Promise.when(pUser, pStream).then(function(user,stream) {
                twitch.streamers.set(streamer, new StreamerView({
                    name: streamer,
                    url: cast stream._links.get('self'),
                    status: cast stream._stream.get('status'),
                    img: cast user.get('icon'),
                }));
            });
        }
    }
    static function getData() {
        // haxe.Json.parse(haxe.Resource.getString("twitch"));
        for (i in 0...streamers.length) {
            trace('Getting data for ${streamers[i]}...');
            getStreamerData(i);
        }
    }
    static function getStreamerData(index) {
        var cookie_stream = 'stream_${streamers[index]}';
        var cookie_user = 'user_${streamers[index]}';
        // get stream data
        if (js.Cookie.exists(cookie_stream)) {
            streamCallback[index](js.Cookie.get(cookie_stream));
        } else {
            Web.ajax({url: 'https://wind-bow.gomix.me/twitch-api/streams/${streamers[index]}',
                options: ['callback' => 'Main.streamCallback[$index]']});
        }
        // get user data
        if (js.Cookie.exists(cookie_user)) {
            userCallback[index](js.Cookie.get(cookie_user));
        } else {
            Web.ajax({url: 'https://wind-bow.gomix.me/twitch-api/users/${streamers[index]}',
                options: ['callback' => 'Main.userCallback[$index]']});
        }
    }

    public static var streamCallback = [
        for (i in streamers) function(data:Dynamic) {
            streams[i].resolve(data);
        }
    ];
    public static var userCallback = [
        for (i in streamers) function(data:Dynamic) {
            users[i].resolve(data);
        }
    ];
}

typedef StreamerData = {
    var name : String;
    var url : String;
    var status : String;
    var img : String;
};

class Twitch implements Mithril {
    public var streamers : Map<String, StreamerView>;
    public function new(streamers:Array<String>) {
        this.streamers = new Map<String, StreamerView>();
        for(streamer in streamers) {
            this.streamers.set(streamer, new StreamerView({
                name: streamer,
                url: "#",
                status: 'Offline',
                img: "#",
            }));
        }
    }
    public function view() [
        m('h1', 'Twitch Streamers'),
            m('.streamers', [for (streamer in streamers.keys()) m(streamers.get(streamer))]),
    ];
}

typedef Stream = {
    @:optional var stream : Dynamic;
    @:optional var display_name : Dynamic;
    @:optional var _links : Dynamic;
};

typedef User = {
    @:optional var imgUrl : Dynamic;
};

class StreamerView implements Mithril {
    public var data : StreamerData;

    public function new(data:StreamerData) {
        this.data = data;
    }
    public function view() m('.streamerview', [
        m('img.logosmall', {src: data.img}),
        m('a.username', {href: data.url}, m('h3', data.name)),
        m('p.status', data.status),
    ]);
}

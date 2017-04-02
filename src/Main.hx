import mithril.M;
import js.Browser;

using Reflect;
/* TODO:
 * Deduplicate data - find just one place to store it
 * Redesign components so they aren't calling each othres public functions
 willy nilly
 */
@:expose
class Main {
    static var twitch:Twitch;
    static var streamers = ["ESL_SC2", "OgamingSC2", "cretetion", "freecodecamp", "storbeck", "habathcx", "RobotCaleb", "noobs2ninjas"];
    static function main() {
        twitch = new Twitch(streamers, getData);
        M.mount(js.Browser.document.body, twitch);
    }
    static function getData() {
        haxe.Json.parse(haxe.Resource.getString("twitch"));
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
            trace('Got stream data for ${i}');
            js.Cookie.set('stream_$i', data.toString());
            twitch.setStream(i,data);
        }
    ];
    public static var userCallback = [
        for (i in streamers) function(data:Dynamic) {
            trace('Got stream data for ${i}');
            js.Cookie.set('user_$i', data.toString());
            twitch.setUser(i,data);
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
    var streamers : Map<String, StreamerView>;
    public function new(streamers:Array<String>, getData) {
        this.streamers = new Map<String, StreamerView>();
        for(streamer in streamers) {
            this.streamers.set(streamer, new StreamerView({
                name: streamer,
                url: "#",
                status: 'Offline',
                img: "#",
            }));
        }
        M.redraw();
        getData();
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

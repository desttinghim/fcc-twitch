import mithril.M;
import js.Browser;

using Reflect;

@:expose
class Main {
    static var twitch:Twitch;
    static function main() {
        twitch = new Twitch();
        M.mount(js.Browser.document.body, twitch);
        getData();
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
    public static var streamers = ["ESL_SC2", "OgamingSC2", "cretetion", "freecodecamp", "storbeck", "habathcx", "RobotCaleb", "noobs2ninjas"];

    public static var streamCallback = [
        for (i in streamers) function(data:Dynamic) {
            trace('Got stream data for ${i}');
            js.Cookie.set('stream_$i', data.toString(), 60);
            twitch.setStream(i,data);
        }
    ];
    public static var userCallback = [
        for (i in streamers) function(data:Dynamic) {
            trace('Got stream data for ${i}');
            js.Cookie.set('user_$i', data.toString(), 60);
            twitch.setUser(i,data);
        }
    ];
}

class Twitch implements Mithril {
    var loaded : Bool;
    var streamers : Map<String, StreamerView>;
    public function new() {
        loaded = false;
        streamers = new Map<String, StreamerView>();
        M.redraw();
    }
    public function view() [
        m('h1', 'Twitch Streamers'),
        loaded ? m('.streamers', [for (streamer in streamers.keys()) m(streamers.get(streamer))])
        : m('.loading', 'Loading...'),
    ];
    public function setStream(name, data) {
        if (data == null) return;

        if(!streamers.exists(name)) streamers.set(name, new StreamerView(name));
        streamers.get(name).setStream(data);
        if(streamers.exists(name)) loaded = true;
        M.redraw();
    }
    public function setUser(name, data) {
        if (data == null) return;

        if(!streamers.exists(name)) streamers.set(name, new StreamerView(name));
        streamers.get(name).setUser(data);
        if(streamers.exists(name)) loaded = true;
        M.redraw();
    }
}

class StreamerView implements Mithril {
    var user : Dynamic;
    var stream : Dynamic;
    var _stream : Dynamic;
    var _links : Dynamic;

    var error : String;
    var name : String;
    var url : String;
    var imgUrl : String;
    var status : String;

    public function new(name) {
        this.name = name;
    }
    public function view() m('.streamerview',
    error == null ? [
        m('img.logosmall', {src: imgUrl}),
        m('a.username', {href: url}, m('h3', name)),
        m('p.status', _stream == null ? "Offline" : status),
    ] : [
        m('h3', 'Error: $error'),
    ]);

    public function setUser(data) {
        user = data;
        this.imgUrl = Reflect.getProperty(this.user, "logo");
    }

    public function setStream(data) {
        stream = data;
        if (Reflect.hasField(stream, "error")) {
            error = stream.getProperty("error");
            return;
        }
        error = null;
        this._stream = stream.getProperty("stream");
        this._links = stream.getProperty("_links");
        this.url = _stream.getProperty("channel");
        this.status = _stream.getProperty("status");

        trace(_stream.fields());
    }
}

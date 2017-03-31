import mithril.M;

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
            Web.ajax({
                url: 'https://wind-bow.gomix.me/twitch-api/streams/${streamers[i]}',
                options: [
                    'callback' => 'Main.dataCallback[$i]',
                ]
            });
        }
        trace('Getting data...');
    }
    public static var streamers = ["ESL_SC2", "OgamingSC2", "cretetion", "freecodecamp", "storbeck", "habathcx", "RobotCaleb", "noobs2ninjas"];
    public static var dataCallback = [
        for (i in streamers) function(data:Dynamic){twitch.setData(i,data);}
    ];
}

class Twitch implements Mithril {
    var loaded : Bool;
    var data : Map<String, Dynamic>;
    public function new() {
        loaded = false;
        data = ["" => ""];
        M.redraw();
    }
    public function view() [
        m('h1', 'Twitch Streamers'),
        loaded ? m('.streamers', [for (datum in data.keys()) m(new StreamerView(datum, data.get(datum)))])
        : m('.loading', 'Loading...'),
    ];
    public function setData(name, data) {
        if (data == null) return;
        loaded = true;
        this.data.set(name, data);
        M.redraw();
    }
}

class StreamerView implements Mithril {
    var data : Dynamic;
    var stream : Dynamic;
    var _links : Dynamic;

    var error : String;
    var name : String;
    var url : String;
    var status : String;
    public function new(name, data) {
        this.data = data;
        if (Reflect.hasField(data, "error")) {
            error = Reflect.getProperty(data, "error");
            return;
        }
        error = null;
        this.stream = Reflect.getProperty(data, "stream");
        this._links = Reflect.getProperty(data, "_links");
        this.name = name;

        this.url = Reflect.getProperty(stream, "url");
        this.status = Reflect.getProperty(stream, "status");
    }
    public function view() m('.streamerview',
    error == null ? [
        m('a', {href: url}, m('h3', name)),
        m('p.status', status == null ? "Offline" : status),
    ] : [
        m('h3', 'Error: $error'),
        //for (field in data.fields()) m('p', field + " " + Reflect.getProperty(data, field)),
    ]);
}
//
// typedef TwitchRespone = Array<{
//     @:optional var stream : StreamInfo;
//     @:optional var _links : Links;
// }>;
//
// typedef StreamInfo = {
//     @:optional var mature : Bool;
//     @:optional var status : String;
//     @:optional var broadcaster_language : String;
//     @:optional var display_name : String;
//     @:optional var game : String;
//     @:optional var _id : Int;
//     @:optional var name : String;
//     @:optional var created_at : String;
//     @:optional var updated_at : String;
//     @:optional var delay : String;
//     @:optional var logo : String;
//     @:optional var banner : String;
//     @:optional var video_banner : String;
//     @:optional var background : String;
//     @:optional var profile_banner : String;
//     @:optional var profile_banner_background_color : String;
//     @:optional var partner : Bool;
//     @:optional var url : String;
//     @:optional var views : Int;
//     @:optional var followers : Int;
//     @:optional var _links : Links;
// };
//
// typedef Links = {
//     self : String,
//     follows : String,
//     commercial : String,
//     stream_key : String,
//     chat : String,
//     subscriptions : String,
//     editors : String,
//     teams : String,
//     videos : String,
// };

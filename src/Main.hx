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
        Web.ajax({
            url: 'https://wind-bow.gomix.me/twitch-api/streams/freecodecamp',
            options: [
                'callback' => 'Main.dataCallback',
            ]
        });
        trace('Getting data...');
    }
    public static function dataCallback(data:Dynamic) {
        trace(data);
        twitch.setData(data);
    }
}

class Twitch implements Mithril {
    var loaded : Bool;
    var data : Array<Dynamic>;
    public function new() {
        loaded = false;
        data = [];
        for (i in data) {
            trace(i.fields());
        }
        M.redraw();
    }
    public function view() [
        m('h1', 'Twitch Streamers'),
        loaded ? m('.streamers', [for (datum in data) m(new StreamerView(datum))])
        : m('.loading', 'Loading...'),
    ];
    public function setData(data) {
        if (data == null) return;
        loaded = true;
        this.data = data;
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
    public function new(data) {
        this.data = data;
        if (Reflect.hasField(data, "error")) {
            error = Reflect.getProperty(data, "error");
            return;
        }
        error = null;
        this.stream = Reflect.getProperty(data, "stream");
        this.name = Reflect.getProperty(data, "display_name");
        this._links = Reflect.getProperty(data, "_links");

        this.url = Reflect.getProperty(stream, "url");
        this.status = Reflect.getProperty(stream, "status");
        if (stream != null && name == null) name = Reflect.getProperty(stream, "display_name");
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

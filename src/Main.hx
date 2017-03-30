import mithril.M;

using Reflect;

class Main {
    static function main() {M.mount(js.Browser.document.body, new Twitch());}
}

class Twitch implements Mithril {
    var loaded : Bool;
    var data : Array<Dynamic>;
    public function new() {
        loaded = false;
        data = getData();
        for (i in data) {
            trace(i.fields());
        }
        M.redraw();
    }
    public function view() [
        for (datum in data) m(new StreamerView(datum))
    ];
    function getData() {
        return haxe.Json.parse(haxe.Resource.getString("twitch"));
    }
}

class StreamerView implements Mithril {
    var data : Dynamic;
    var stream : Dynamic;
    var name : String;
    public function new(data) {
        this.data = data;
        this.stream = Reflect.getProperty(data, "stream");
        this.name = Reflect.getProperty(data, "display_name");
        if (stream != null && name == null) name = Reflect.getProperty(stream, "display_name");
    }
    public function view() m('.streamerview', [
        m('h2', name),
        m('p.online', stream == null ? 'Offline' : 'Online'),
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

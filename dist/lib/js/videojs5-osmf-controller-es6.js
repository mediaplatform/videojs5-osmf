'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _video = require('video.js');

var _video2 = _interopRequireDefault(_video);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

//import videojs from './video.js/src/js/video.js';

var Component = _video2.default.getComponent('Component');
var Flash = _video2.default.getComponent('Flash');
var Tech = _video2.default.getComponent('Tech');

var Osmf = function (_Flash) {
    _inherits(Osmf, _Flash);

    function Osmf(options, ready) {
        _classCallCheck(this, Osmf);

        return _possibleConstructorReturn(this, (Osmf.__proto__ || Object.getPrototypeOf(Osmf)).call(this, options, ready));
    }

    return Osmf;
}(Flash);

Osmf.formats = {
    'application/adobe-f4m': 'F4M',
    'video/f4m': 'F4M',
    'application/adobe-f4v': 'F4V',
    'application/dash+xml': 'MPD'
};

Osmf.canPlaySource = function (src) {
    var type = src.type.replace(/;.*/, '').toLowerCase();
    return type in Osmf.formats ? 'maybe' : '';
};

// Create setters and getters for attributes
var _api = Osmf.prototype;
var _readWrite = 'rtmpConnection,rtmpStream,preload,defaultPlaybackRate,playbackRate,autoplay,loop,mediaGroup,controller,controls,volume,muted,defaultMuted'.split(',');
var _readOnly = 'error,seeking,played,streamType,currentLevel,levels,networkState,readyState,initialTime,startOffsetTime,paused,ended,videoWidth,videoHeight'.split(',');

function _createSetter(attr) {
    var attrUpper = attr.charAt(0).toUpperCase() + attr.slice(1);
    _api['set' + attrUpper] = function (val) {
        return this.el_.vjs_setProperty(attr, val);
    };
}

function _createGetter(attr) {
    _api[attr] = function () {
        return this.el_.vjs_getProperty(attr);
    };
}

// Create getter and setters for all read/write attributes
for (var i = 0; i < _readWrite.length; i++) {
    _createGetter(_readWrite[i]);
    _createSetter(_readWrite[i]);
}

// Create getters for read-only attributes
for (var _i = 0; _i < _readOnly.length; _i++) {
    _createGetter(_readOnly[_i]);
}

Osmf.prototype.paused = function () {
    return this.el_.vjs_paused();
};

//Not sure this function is needed
Osmf.prototype.streamStatus = function () {
    return this.el_.streamStatus();
};

_video2.default.options.osmf = {};
_video2.default.options.techOrder.push('Osmf');
_video2.default.options.osmf.swf = 'videojs-osmf.swf';

Component.registerComponent('Flash', Flash);
Tech.registerTech('Osmf', Osmf);

exports.default = Osmf;

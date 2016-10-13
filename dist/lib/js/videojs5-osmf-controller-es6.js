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

_video2.default.options.osmf = {};
Tech.registerTech('Osmf', Osmf);
_video2.default.options.techOrder.push('Osmf');

exports.default = Osmf;

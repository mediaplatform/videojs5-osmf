import videojs from 'video.js';

const Component = videojs.getComponent('Component');
const Flash = videojs.getComponent('Flash');
const Tech = videojs.getComponent('Tech');

class Osmf extends Flash {
    constructor(options, ready) {
        super(options, ready);
        this.initialBufferTime = options.initialBufferTime || 2;
        this.ready(function(){
            this.el_.vjs_setProperty('initialBufferTime', this.initialBufferTime);
        }, true);
    }
}

Osmf.formats = {
    'application/adobe-f4m': 'F4M',
    'video/f4m': 'F4M',
    'application/adobe-f4v': 'F4V',
    'application/dash+xml': 'MPD'
};

Osmf.canPlaySource = function(src){
    var type = src.type.replace(/;.*/, '').toLowerCase();
    return type in Osmf.formats ? 'maybe' : '';
};

// Create setters and getters for attributes
const _api = Osmf.prototype;
const _readWrite = 'initialBufferTime,rtmpConnection,rtmpStream,preload,defaultPlaybackRate,playbackRate,autoplay,loop,mediaGroup,controller,controls,volume,muted,defaultMuted'.split(',');
const _readOnly = 'seeking,played,streamType,currentLevel,levels,networkState,readyState,initialTime,startOffsetTime,paused,ended,videoWidth,videoHeight'.split(',');

function _createSetter(attr){
    var attrUpper = attr.charAt(0).toUpperCase() + attr.slice(1);
    _api['set'+attrUpper] = function(val){
        return this.el_.vjs_setProperty(attr, val);
    };
}

function _createGetter(attr) {
    _api[attr] = function(){
        return this.el_.vjs_getProperty(attr);
    };
}

// Create getter and setters for all read/write attributes
for (let i = 0; i < _readWrite.length; i++) {
    _createGetter(_readWrite[i]);
    _createSetter(_readWrite[i]);
}

// Create getters for read-only attributes
for (let i = 0; i < _readOnly.length; i++) {
    _createGetter(_readOnly[i]);
}

Osmf.prototype.paused = function(){
    return this.el_.vjs_paused();
};

Osmf.prototype.setCurrentTime = function(time){
    if (time) {
        Flash.setCurrentTime(time);
    }
};

//Not sure this function is needed
Osmf.prototype.streamStatus = function(){
    return this.el_.streamStatus();
};

videojs.options.osmf = {};
videojs.options.techOrder.push('Osmf');

Component.registerComponent('Flash', Flash);
Tech.registerTech('Osmf', Osmf);

export default Osmf;

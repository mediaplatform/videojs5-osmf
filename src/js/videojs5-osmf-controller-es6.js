import videojs from 'video.js';

const Flash = videojs.getComponent('Flash');
const Tech = videojs.getComponent('Tech');

class Osmf extends Flash {
    constructor(options, ready) {
        super(options, ready);
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

videojs.options.osmf = {};
Tech.registerTech('Osmf', Osmf);
videojs.options.techOrder.push('Osmf');

export default Osmf;

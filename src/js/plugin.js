import videojs from 'video.js';
import videojs-osmf from './videojs-osmf-controller';

/**
 * The video.js OSMF plugin.
 *
 * @param {Object} options
 */
const plugin = function (options) {
    dailymotion(this, options);
};

videojs.plugin('osmf', plugin);

export default plugin;
package org.osmf.net
{
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;

	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.MulticastResource;
	import org.osmf.net.NetClient;
	import org.osmf.net.NetStreamCodes;
	import org.osmf.net.NetStreamUtils;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.traits.TimeTrait;

	public class ExtendedTimeTrait extends TimeTrait
	{

		public function ExtendedTimeTrait(netStream:NetStream, resource:MediaResourceBase, defaultDuration:Number=NaN)
		{
			super();

			this.netStream = netStream;
			//NetClient(netStream.client).addHandler(NetStreamCodes.ON_META_DATA, onMetaData);
			NetClient(netStream.client).addHandler(NetStreamCodes.ON_PLAY_STATUS, onPlayStatus);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			this.resource = resource;

			if (isNaN(defaultDuration) == false)
			{
				setDuration(defaultDuration);
			}
			var streamResource:MulticastResource = resource as MulticastResource;
			if (streamResource != null && streamResource.groupspec != null && streamResource.groupspec.length > 0)
			{
				multicast = true;
				//setDuration(Number.MIN_VALUE);
				setDuration(Infinity);
			}
		}
		//override protected function
		/**
		 * @private
		 */
		override public function get currentTime():Number
		{
			if (multicast)
			{
				//return 0;
			}

			// If at the end of the video, make sure the duration matches the currentTime.
			// Work around for FP-3724.  Only apply duration offset at the end - or else the seek(0) doesn't goto 0.
			if (durationOffset == (duration - (netStream.time - _audioDelay)))
			{
				return netStream.time - _audioDelay + durationOffset;
			}
			else
			{
				return netStream.time - _audioDelay;
			}
		}
		private function onNetStatus(event:NetStatusEvent):void
		{
			//trace("code is " + event.info.code);
			switch (event.info.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_STOP:
					// For progressive,	NetStream.Play.Stop means playback
					// has completed.  But this isn't fired for streaming.
					if (NetStreamUtils.isStreamingResource(resource) == false)
					{
						signalComplete();
					}
					break;
				case NetStreamCodes.NETSTREAM_PLAY_UNPUBLISH_NOTIFY:
					// When a live stream is unpublished, we should signal that
					// the stream has stopped.
					//signalComplete();
					dispatchEvent(new Event("video.complete", true));
					break;
			}
		}
		private function onPlayStatus(event:Object):void
		{
			switch(event.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_COMPLETE:
					// For streaming, NetStream.Play.Complete means playback
					// has completed.  But this isn't fired for progressive. We can't use signalComplete, we need to bypass OSMF here.
					//signalComplete();
					dispatchEvent(new Event("video.complete", true));
			}
		}
		/**
		 * We have to change the duration , given that audioDelay isn't enough to
		 * fix that netStream.time has from the detected duration.  This isn't
		 * pre computable, since PLAY_STOP is fired at
		 * non-deterministic intervals when the video is near ending.
		 **/
		override protected function signalComplete():void
		{
			if ((netStream.time - audioDelay) != duration)
			{
				durationOffset = duration - (netStream.time - audioDelay);
			}
			super.signalComplete();
		}

		//private var _metadataCount:int = 0;
		private var _audioDelay:Number = 0;
		private var multicast:Boolean = false;
		private var durationOffset:Number = 0;
		private var audioDelay:Number = 0;
		private var netStream:NetStream;
		private var resource:MediaResourceBase;
	}
}

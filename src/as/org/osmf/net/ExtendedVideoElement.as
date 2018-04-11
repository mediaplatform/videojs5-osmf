package org.osmf.net
{
	import flash.net.NetStream;
	import org.osmf.media.videoClasses.VideoSurface;
	import org.osmf.elements.LightweightVideoElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.net.NetLoader;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.net.NetStreamAudioTrait;
	import org.osmf.net.NetStreamBufferTrait;
	import org.osmf.net.NetStreamCodes;
	import org.osmf.net.NetStreamDisplayObjectTrait;
	import org.osmf.net.NetStreamDynamicStreamTrait;
	import org.osmf.net.NetStreamPlayTrait;
	import org.osmf.net.NetStreamSeekTrait;
	import org.osmf.utils.OSMFSettings;
	import org.osmf.events.TimeEvent;
	import org.osmf.net.NetStreamAlternativeAudioTrait;
	import org.osmf.traits.*;
	import org.osmf.net.NetClient;
	import flash.external.ExternalInterface;

	import com.videojs.utils.Console;

	public class ExtendedVideoElement extends LightweightVideoElement
	{
		private var _stream:NetStream;
		private var _videoSurface:VideoSurface;
		//private var stream:NetStream;

		public function ExtendedVideoElement(resource:MediaResourceBase=null, loader:NetLoader=null)
		{
			Console.log('ExtendedVideoElement constructor');
			super(null, null);
			super.loader = loader;
			this.resource = resource;
		}
		override protected function processReadyState():void
		{
			//_vars = this.resource.getMetadataValue("vars");
			var loadTrait:NetStreamLoadTrait = getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
			_stream = loadTrait.netStream;

			_videoSurface = new VideoSurface(OSMFSettings.enableStageVideo && OSMFSettings.supportsStageVideo, createVideo);
			//_videoSurface.smoothing = _smoothing;
			//_videoSurface.deblocking = _deblocking;

			_videoSurface.attachNetStream(_stream);

			Console.log('About to add client handlers');
			NetClient(_stream.client).addHandler("KillStream", handleKillStream);
			NetClient(_stream.client).addHandler("ScriptCommand", handleScriptCommand);
			NetClient(_stream.client).addHandler('OverlayCommand', handleOverlayCommand);

			function handleScriptCommand(cmd:String):void
			{

				if(ExternalInterface.available)
				{
					//Console.log('ScriptCommand', cmd.toString());
					//ExternalInterface.call("videojs.Osmf.Flash_ScriptCommand", cmd.toString());
					//ExternalInterface.call("videojs.Osmf.VIDEO_ScriptCommand", cmd.toString());
					ExternalInterface.call("videojs.Osmf.NS_ScriptCommand", cmd.toString());
				}
			}
			function handleKillStream(cmd:String):void
			{
				_stream.close();
			}
			function handleOverlayCommand(cmd:String):void
			{

				if(ExternalInterface.available)
				{
					//Console.log('ScriptCommand', cmd.toString());
					ExternalInterface.call("videojs.Osmf.NS_OverlayCommand", cmd);
				}
			}
			finishLoad();
		}

		private function finishLoad():void
		{
			var loadTrait:NetStreamLoadTrait = getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;

			// setup dvr trait
			var dvrTrait:MediaTraitBase = loadTrait.getTrait(MediaTraitType.DVR) as DVRTrait;
			if (dvrTrait != null)
			{
				addTrait(MediaTraitType.DVR, dvrTrait);
			}

			// setup audio trait
			var audioTrait:MediaTraitBase = loadTrait.getTrait(MediaTraitType.AUDIO) as AudioTrait;
			if (audioTrait == null)
			{
				audioTrait = new NetStreamAudioTrait(_stream);
			}
			addTrait(MediaTraitType.AUDIO, audioTrait);

			// setup buffer trait
			var bufferTrait:BufferTrait = loadTrait.getTrait(MediaTraitType.BUFFER) as BufferTrait;
			if (bufferTrait == null)
			{
				bufferTrait = new NetStreamBufferTrait(_stream, _videoSurface);
			}
			addTrait(MediaTraitType.BUFFER, bufferTrait);


			// setup time trait
			var timeTrait:TimeTrait = loadTrait.getTrait(MediaTraitType.TIME) as TimeTrait;
			if (timeTrait == null)
			{
				//timeTrait = new NetStreamTimeTrait(stream, loadTrait.resource, defaultDuration);
				timeTrait = new ExtendedTimeTrait(_stream, loadTrait.resource, defaultDuration);
			}
			addTrait(MediaTraitType.TIME, timeTrait);

			// setup display object trait
			var displayObjectTrait:DisplayObjectTrait = loadTrait.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
			if (displayObjectTrait == null)
			{
				displayObjectTrait = new NetStreamDisplayObjectTrait(_stream, _videoSurface, NaN, NaN);
			}
			addTrait(MediaTraitType.DISPLAY_OBJECT,	displayObjectTrait);

			// setup play trait
			var playTrait:PlayTrait = loadTrait.getTrait(MediaTraitType.PLAY) as PlayTrait;
			if (playTrait == null)
			{
				var reconnectStreams:Boolean = false;
				CONFIG::FLASH_10_1
				{
					reconnectStreams = (loader as NetLoader).reconnectStreams;
				}
				playTrait = new NetStreamPlayTrait(_stream, resource, reconnectStreams, loadTrait.connection);
			}
			addTrait(MediaTraitType.PLAY, playTrait);

			// setup seek trait
			var seekTrait:SeekTrait = loadTrait.getTrait(MediaTraitType.SEEK) as SeekTrait;
			if (seekTrait == null && NetStreamUtils.getStreamType(resource) != StreamType.LIVE)
			{
				seekTrait = new NetStreamSeekTrait(timeTrait, loadTrait, _stream, _videoSurface);
	  		}
	  		if (seekTrait != null)
	  		{
	  			// Only add the SeekTrait if/when the TimeTrait has a duration,
	  			// otherwise the user might try to seek when a seek cannot actually
	  			// be executed (FM-440).
	  			if (isNaN(timeTrait.duration) || timeTrait.duration == 0)
	  			{
	  				timeTrait.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);

	  				function onDurationChange(event:TimeEvent):void
	  				{
	  					timeTrait.removeEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);

	  					addTrait(MediaTraitType.SEEK, seekTrait);
	  				}
	  			}
	  			else
	  			{
	    			addTrait(MediaTraitType.SEEK, seekTrait);
	    		}
	    	}

			// setup dynamic resource trait
			var dsResource:DynamicStreamingResource = resource as DynamicStreamingResource;
			if (dsResource != null && loadTrait.switchManager != null)
			{
				var dsTrait:MediaTraitBase = loadTrait.getTrait(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait;
				if (dsTrait == null)
				{
					dsTrait = new NetStreamDynamicStreamTrait(_stream, loadTrait.switchManager, dsResource);
				}
				addTrait(MediaTraitType.DYNAMIC_STREAM, dsTrait);
			}

			//setup alternative audio trait
			var sResource:StreamingURLResource = resource as StreamingURLResource;
			if (sResource != null && sResource.alternativeAudioStreamItems != null && sResource.alternativeAudioStreamItems.length > 0)
			{
				var aaTrait:AlternativeAudioTrait = loadTrait.getTrait(MediaTraitType.ALTERNATIVE_AUDIO) as AlternativeAudioTrait;
				if (aaTrait == null)
				{
					aaTrait = new NetStreamAlternativeAudioTrait(_stream, sResource);
				}
				addTrait(MediaTraitType.ALTERNATIVE_AUDIO, aaTrait);
			}
		}
	}
}

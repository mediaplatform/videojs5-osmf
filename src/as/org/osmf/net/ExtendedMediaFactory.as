package org.osmf.net
{

	import org.osmf.net.NetLoader;
	import org.osmf.net.MulticastNetLoader;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaElement;
	import org.osmf.net.ExtendedVideoElement;
	import org.osmf.net.NetConnectionFactory;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.net.httpstreaming.HTTPStreamingNetLoader;

	import com.videojs.utils.Console;

	public class ExtendedMediaFactory extends DefaultMediaFactory
	{
		private var netLoader:NetLoader;
		private var _multicastNetLoader:MulticastNetLoader;
		private var _httpStreamingNetLoader:HTTPStreamingNetLoader;

		public function ExtendedMediaFactory()
		{
			Console.log('ExtendedMediaFactory constructor');
			super();

			addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, handleMediaElementCreation, false, 0, true);

			netLoader = new NetLoader();
			addItem
			( new MediaFactoryItem
				( "com.mediaplayer.mediaplatform.elements.video"
					, netLoader.canHandleResource
					, function():MediaElement
					{
						return new ExtendedVideoElement(null, netLoader);
					}
				)
			);

			_httpStreamingNetLoader = new HTTPStreamingNetLoader();
			addItem
				( new MediaFactoryItem
					( "com.mediaplayer.mediaplatform.elements.video.httpstreaming"
					, _httpStreamingNetLoader.canHandleResource
					, function():MediaElement
						{
							return new ExtendedVideoElement(null, _httpStreamingNetLoader);
						}
					)
				);

			var mcFactory:NetConnectionFactory = new NetConnectionFactory();
			mcFactory.timeout = 5000;
			_multicastNetLoader = new MulticastNetLoader(mcFactory);
			addItem
			( new MediaFactoryItem
				( "com.mediaplayer.mediaplatform.elements.multicast.video"
					, _multicastNetLoader.canHandleResource
					, function():MediaElement
					{
						return new ExtendedVideoElement(null, _multicastNetLoader);
					}
				)
			);

		}
		private function handleMediaElementCreation(evt:MediaFactoryEvent):void
		{

		}
	}
}

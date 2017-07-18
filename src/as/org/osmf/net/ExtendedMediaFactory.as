package org.osmf.net
{

	import org.osmf.net.NetLoader;
	import org.osmf.net.MulticastNetLoader;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaElement;
	import org.osmf.net.ExtendedVideoElement;
	import org.osmf.events.MediaFactoryEvent;

	import com.videojs.utils.Console;

	public class ExtendedMediaFactory extends DefaultMediaFactory
	{
		private var netLoader:NetLoader;
		private var _multicastNetLoader:MulticastNetLoader;

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

			_multicastNetLoader = new MulticastNetLoader();
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

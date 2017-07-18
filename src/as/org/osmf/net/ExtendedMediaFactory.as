package org.osmf.net
{

	import org.osmf.net.NetLoader;
	import org.osmf.net.MulticastNetLoader;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaElement;
	import org.osmf.net.ExtendedVideoElement;

	public class ExtendedMediaFactory extends DefaultMediaFactory
	{
		private var netLoader:NetLoader;
		private var multicastNetLoader:MulticastNetLoader;

		public function ExtendedMediaFactory()
		{
			super();

			//addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, handleMediaElementCreation, false, 0, true);

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

			multicastNetLoader = new MulticastNetLoader();
			addItem
			( new MediaFactoryItem
				( "com.mediaplayer.mediaplatform.elements.video"
					, multicastNetLoader.canHandleResource
					, function():MediaElement
					{
						return new ExtendedVideoElement(null, multicastNetLoader);
					}
				)
			);

		}
	}
}

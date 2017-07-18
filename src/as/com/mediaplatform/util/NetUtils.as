package com.mediaplatform.util
{

	import org.osmf.media.URLResource;
	import org.osmf.net.*;
	import org.osmf.utils.URL;

	public class NetUtils
	{
		public function NetUtils()
		{
		}
		public static function isRTMFPStream(url:String):Boolean
		{
			var result:Boolean = false;
			if (url != null)
			{
				var theURL:URL = new URL(url);
				var protocol:String = theURL.protocol;
				if (protocol != null && protocol.length > 0)
				{
					result = (protocol.search(/^rtmfp$/i) != -1);
				}
			}

			return result;
		}
		public static function isArchiveStream(url:String):Boolean
		{
			var result:Boolean = false;
			if (url != null)
			{
				result = (url.search(/archive/i) != -1 || url.search(/ondemand/i) != -1 || url.search(/vod/i) != -1);
			}
			return result;
		}
		public static function isStreamingResource(url:String):Boolean
		{
			var result:Boolean = false;
			if (url != "")
			{
				//var urlResource:URLResource = resource as URLResource;
				//if (urlResource != null)
				//{
					//result = IVTNetUtils.isRTMFPStream(urlResource.url);
					result = (url.search(/live/i) != -1) || (url.search(/fms4multicast/i) != -1);
				//}
			}
			if(isRTMFPStream(url))
			{
				result = true;
			}
			return result;
		}
		public static function isF4V(url:String):Boolean
		{
			var result:Boolean = false;
			if(url != "")
			{
				result = StringUtils.contains(url, "f4v");
			}
			return result
		}
		public static function getStreamNameFromURL(url:String, urlIncludesFMSApplicationInstance:Boolean=false):String
		{
			var streamName:String = "";
			if (url != null)
			{
				if (isRTMFPStream(url))
				{
					var mcURL:FMSURL = new FMSURL(url, urlIncludesFMSApplicationInstance);
					streamName = mcURL.streamName;

					if (mcURL.query != null && mcURL.query != "")
					{
						 streamName += "?" + mcURL.query;
					}
				}
				else
				{
					streamName = url;
				}
			}
			return streamName;
		}
		public static function parseMulticastURL(url:String, vo:Object):String
		{
			if(!StringUtils.contains(url, "?"))
			{
				return url;
			}
			var qs:String = StringUtils.afterFirst(url, "?");
			var arr:Array = qs.split("&");//trace(qs);
			var key:String;
			var prop:String;
			for each(var item:Object in arr)
			{
				key = item.split("=")[0];
				prop = item.split("=")[1];
				vo[key] = prop;
			}
			return StringUtils.beforeFirst(url, "?");
		}
		public static function parseProtocol(url:String, vo:Object):String
		{
			if(vo.protocol == "")return url
			return vo.protocol + "://" + StringUtils.afterFirst(url, "//");
		}
		public static function parseURLForAppInstance(url:String):Boolean
		{
			var urlPart1:String = StringUtils.afterFirst(url, "//");
			var urlPart2:String = StringUtils.afterFirst(urlPart1, "/");
			var urlPart3:String = StringUtils.afterFirst(urlPart2, "/");
			if(StringUtils.contains(urlPart3, "/"))
			{
				return true;
			}
			else
			{
				return false;
			}


		}
	}
}

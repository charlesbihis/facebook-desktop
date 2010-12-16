package com.facebook.desktop.control.api
{
	import com.facebook.desktop.model.Model;
	import com.facebook.graph.FacebookDesktop;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class MarkNotificationsRead
	{
		private static const API_CALL:String = "notifications.markRead";
		
		private static var model:Model = Model.instance;
		private static var logger:ILogger = Log.getLogger("com.facebook.desktop.control.api.MarkNotificationsRead");
		
		public var notificationIds:String;
		
		public function execute(callback:Function = null):void
		{
			var args:Object = new Object();
			args.notification_ids = notificationIds;
			
			FacebookDesktop.callRestAPI(API_CALL, handler, args);
			
			function handler(success:Object, fail:Object):void
			{
				if (success as Boolean)
				{
					logger.info("Marked notifications [{0}] as read", notificationIds.toString());
				}  // if statement
				else
				{
					logger.error("Error marking notifications [{0}] as read.  Error: " + fail.toString());
				}  // else statement
				
				if (callback != null)
				{
					callback(success, fail);
				}  // if statement
			}  // handler
		}  // execute
	}
}
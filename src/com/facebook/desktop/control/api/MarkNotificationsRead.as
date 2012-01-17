package com.facebook.desktop.control.api
{
	import com.facebook.desktop.model.Model;
	import com.facebook.graph.FacebookDesktop;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.ObjectUtil;

	public class MarkNotificationsRead implements ICommand
	{
		private static const API:String = "notifications.markRead";
		
		private static var log:ILogger = Log.getLogger("com.facebook.desktop.control.api.MarkNotificationsRead");
		
		public function execute(args:Object = null, callback:Function = null, passThroughArgs:Object = null):void
		{
			FacebookDesktop.callRestAPI(API, moreNotificationsReadHandler, args);
			
			function moreNotificationsReadHandler(success:Object, fail:Object):void
			{
				if (success as Boolean)
				{
					log.info("Marked notifications as read");
				}  // if statement
				else
				{
					log.error("Error marking notifications as read.  Error object: " + ObjectUtil.toString(fail));
				}  // else statement
				
				if (callback != null)
				{
					callback(success, fail);
				}  // if statement
				
				// make sure we call the callback
				if (callback != null && callback is Function)
				{
					callback(success, fail, passThroughArgs);
				}  // if statement
			}  // moreNotificationsReadHandler
		}  // execute
	}  // class declaration
}  // package
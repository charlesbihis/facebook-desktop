package com.facebook.desktop.control.api
{
	import com.facebook.desktop.model.Model;
	import com.facebook.graph.FacebookDesktop;
	
	import flash.events.EventDispatcher;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.ObjectUtil;

	public class GetNewsFeed extends EventDispatcher implements ICommand
	{
		private static const API:String = "/me/home";
		
		private static var model:Model = Model.instance;
		private static var log:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetNewsFeed");
		
		private var args:Object;
		
		public function GetNewsFeed(args:Object = null)
		{
			this.args = args;
		}  // GetNewsFeed
		
		public function execute(args:Object, passThroughArgs:Object):void
		{
			FacebookDesktop.api(API, getNewsFeedHandler, args);
			
			function getNewsFeedHandler(result:Object, fail:Object):void
			{
				if (fail == null)
				{
					if (result != null && result is Array && (result as Array).length > 0)
					{
						var newsFeedUpdates:Array = result as Array;
						for (var i:int = 0; i < newsFeedUpdates.length; i++)
						{
							
						}  // for loop
					}  // if statement
				}  // if statement
				else
				{
					log.error("Request to get latest news feed updates has failed!  Error object: " + ObjectUtil.toString(fail));
				}  // else statement
			}  // getNewsFeedHandler
		}  // execute
	}  // class declaration
}  // package
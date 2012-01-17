package com.facebook.desktop.control.api
{
	import com.facebook.desktop.model.Model;
	import com.facebook.graph.FacebookDesktop;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class GetObject implements ICommand
	{
		private static var logger:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetObject");
		
		public function execute(args:Object = null, callback:Function = null, passThroughArgs:Object = null):void
		{
			if (args != null && args is String)
			{
				FacebookDesktop.api(args as String, getObjectHandler, {include_read:true});
			}  // if statement
			else
			{
				throw new Error("Error fetching object.  Object ID is null.");
			}  // else statement
			
			function getObjectHandler(result:Object, fail:Object):void
			{
				// make sure we call the callback
				if (callback != null && callback is Function)
				{
					callback(result, fail, passThroughArgs);
				}  // if statement
			}  // getObjectHandler
		}  // execute
	}  // class declaration
}  // package
package com.facebook.desktop.control.api
{
	import com.facebook.desktop.model.Model;
	import com.facebook.desktop.model.cache.ApplicationCache;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class GetApplication implements ICommand
	{
		private static var applicationCache:ApplicationCache = ApplicationCache.instance;
		private static var log:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetApplication");
		
		public function GetApplication()
		{
		}  // GetApplication
		
		public function execute(args:Object = null, callback:Function = null, passThroughVariables:Object = null):void
		{
			if (args != null && args is String)
			{
				log.info("Retrieving application object with ID " + args);
				
				if (applicationCache.contains(args as String))
				{
					log.info("Application object with ID " + args + " found in application cache.  Returning cached object instead.");
					callback(applicationCache.get(args as String), passThroughVariables);
				}  // if statement
				else
				{
					var getObjectCommand:GetObject = new GetObject();
					getObjectCommand.execute(args, getObjectHandler);
				}  // else statement
			}  // if statement
			else
			{
				throw new Error("Error fetching application.  Application ID is null.");
			}  // else statement
			
			function getObjectHandler(result:Object, fail:Object, passThroughArgs:Object):void
			{
				if (callback != null)
				{
					log.info("Placing application object with ID " + args + " in application cache");
					applicationCache.put(args as String, result);
					callback(result, fail, passThroughVariables);
				}  // if statement
			}  // getObjectHandler
		}  // execute
	}  // class declaration
}  // package
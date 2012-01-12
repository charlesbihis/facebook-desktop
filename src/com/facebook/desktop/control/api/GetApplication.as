package com.facebook.desktop.control.api
{
	import com.facebook.desktop.model.Model;
	import com.facebook.desktop.model.cache.ApplicationCache;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class GetApplication
	{
		public var applicationId:String;
		
		private static var applicationCache:ApplicationCache = ApplicationCache.instance;
		private static var log:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetApplication");
		
		public function GetApplication(applicationId:String)
		{
			this.applicationId = applicationId;
		}  // GetApplication
		
		public function execute(callback:Function = null, passThroughVariables:Object = null):void
		{
			log.info("Retrieving application object with ID " + applicationId);
			
			if (applicationId != null)
			{
				if (applicationCache.contains(applicationId))
				{
					log.info("Application object with ID " + applicationId + " found in application cache.  Returning cached object instead.");
					callback(applicationCache.get(applicationId), passThroughVariables);
				}  // if statement
				else
				{
					var getObjectCommand:GetObject = new GetObject(applicationId);
					getObjectCommand.execute(getObjectHandler);
				}  // else statement
			}  // if statement
			else
			{
				throw new Error("Error fetching application.  Application ID is null.");
			}  // else statement
			
			function getObjectHandler(result:Object):void
			{
				if (callback != null)
				{
					log.info("Placing application object with ID " + applicationId + " in application cache");
					applicationCache.put(applicationId, result);
					callback(result, passThroughVariables);
				}  // if statement
			}  // getObjectHandler
		}  // execute
	}  // class declaration
}  // package
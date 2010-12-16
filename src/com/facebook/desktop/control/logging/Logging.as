package com.facebook.desktop.control.logging
{
	import com.adobe.air.logging.FileTarget;
	
	import flash.filesystem.File;
	
	import mx.formatters.DateFormatter;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	
	public class Logging
	{
		public static function init():void
		{
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "YYYY-MM-DD";
			
			var logFilePath:String = File.applicationStorageDirectory.nativePath + "\\logs\\" + dateFormatter.format(new Date()) + ".log";
			var file:File = new File(logFilePath);
			var logTarget:FileTarget = new FileTarget(file);
			
			logTarget.filters=["*"];
			logTarget.level = LogEventLevel.ALL;
			logTarget.includeDate = true;
			logTarget.includeTime = true;
			logTarget.includeCategory = true;
			logTarget.includeLevel = true;
			Log.addTarget(logTarget);
		}  // init
	}  // class declaration
}  // package
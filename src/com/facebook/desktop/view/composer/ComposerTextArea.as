package com.facebook.desktop.view.composer
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.events.FlexEvent;
	import mx.managers.FocusManager;
	import mx.resources.ResourceManager;
	import mx.utils.StringUtil;
	
	import spark.components.TextArea;
	
	public class ComposerTextArea extends TextArea
	{
		private static const ENABLED_TEXT_COLOR:uint = 0x333333;
		private static const DISABLED_TEXT_COLOR:uint = 0x808080;
		
		private var shadowText:String = ResourceManager.getInstance().getString("resources", "component.composer.shadowText");
		private var _active:Boolean = true;
		
		public function ComposerTextArea()
		{
			super();
			
			text = shadowText;
			
			// add event listeners
			addEventListener(FocusEvent.FOCUS_IN, focusIn);
			addEventListener(FocusEvent.FOCUS_OUT, focusOut);
			addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
			ResourceManager.getInstance().addEventListener(Event.CHANGE, changeLanguage);
			
			function focusIn(event:FocusEvent):void
			{
				active = true;
				
				if (text == shadowText)
				{
					text = "";
				}  // if statement
			}  // focusIn
			
			function focusOut(event:FocusEvent):void
			{
				active = false;
			}  // focusOut
			
			function changeLanguage(event:Event):void
			{
				// reload the shadow-text (note: this erases whatever message was typed into the composer before - may want to change this logic at some point)
				shadowText = text = ResourceManager.getInstance().getString("resources", "component.composer.shadowText");
			}  // changeLanguage
		}  // GrowableTextArea
		
		[Bindable]
		public function get active():Boolean
		{
			return _active;
		}  // active
		
		public function set active(active:Boolean):void
		{
			_active = active;
			updateState();
		}  // active
		
		private function creationComplete(event:Event):void
		{
			updateState();
		}  // creationComplete
		
		private function updateState():void
		{
			setStyle("color", active ? ENABLED_TEXT_COLOR : DISABLED_TEXT_COLOR);
			
			if (!active && mx.utils.StringUtil.trim(text).length == 0)
			{
				text = shadowText;
			}  // if statement
		}  // updateState
	}  // class declaration
}  // package
package backend;

import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import openfl.net.FileFilter;

enum SaveFileStatus
{
    SUCCESS;
    CANCEL;
    ERROR;
}

/**
 * Class that contains helper functions for requesting files through dialogs.
 */
class FileDialog
{
	public static final JSON_FILE:FileFilter = new FileFilter('JSON Data File', '*.json');

	public static function browseForFile(onFile:FileReference->Void, ?filters:Array<FileFilter>)
    {
		var fileRef:FileReference = new FileReference();

		fileRef.addEventListener(Event.SELECT, function(refEv:Event)
        {
			var selectedFile:FileReference = refEv.target;

			selectedFile.addEventListener(Event.COMPLETE, function(filEv:Event)
            {
				var loadedFile:FileReference = filEv.target;
				onFile(loadedFile);
            });

			selectedFile.load();
        });

		fileRef.browse(filters);
    }

	public static function saveDataToFile(data:Dynamic, ?filename:String, ?onStatus:SaveFileStatus -> Void)
    {
		var fileRef:FileReference = new FileReference();

		fileRef.addEventListener(Event.COMPLETE, function(e:Event) 
        {
			if (onStatus != null)
			    onStatus(SUCCESS);
        });

		fileRef.addEventListener(Event.CANCEL, function(e:Event)
		{
			if (onStatus != null)
			    onStatus(CANCEL);
		});

		fileRef.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event)
		{
			if (onStatus != null)
			    onStatus(ERROR);
		});

		fileRef.save(data, filename);
    }
}
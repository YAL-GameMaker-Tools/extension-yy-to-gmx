package;

import haxe.Json;
import haxe.io.Path;
import neko.Lib;
import sf.gml.SfGmx;
import sf.gml.SfYyExtension;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author YellowAfterlife
 */
class Main {
	
	static function main() {
		var args = Sys.args();
		if (args.length < 2) {
			Sys.println("Use: yy2gmx extension.yy extension.gmx");
			return;
		}
		//
		var yyPath = args[0];
		var yyDir = Path.directory(yyPath);
		var yy:SfYyExtension = Json.parse(File.getContent(yyPath));
		//
		var gmxPath = args[1];
		var gmxDir = Path.withoutExtension(Path.withoutExtension(gmxPath));
		if (!FileSystem.exists(gmxDir)) FileSystem.createDirectory(gmxDir);
		//
		var gmx:SfGmx = SfGmx.parse(GmxTemplate.ext);
		gmx.find("name").text = yy.name;
		gmx.find("version").text = yy.version;
		gmx.find("packageID").text = yy.packageID;
		gmx.find("ProductID").text = yy.productID;
		gmx.find("date").text = yy.date;
		gmx.find("license").text = yy.license;
		// todo: things uncommon
		var gmxFiles = gmx.find("files");
		for (yyFile in yy.files) {
			var gmxFile = new SfGmx("file");
			File.copy(Path.join([yyDir, yyFile.filename]), Path.join([gmxDir, yyFile.filename]));
			gmxFile.addChild(new SfGmx("filename", yyFile.filename));
			gmxFile.addChild(new SfGmx("origname", yyFile.origname));
			gmxFile.addChild(new SfGmx("init", yyFile.init));
			gmxFile.addChild(new SfGmx("final", Reflect.field(yyFile, "final")));
			gmxFile.addChild(new SfGmx("kind", "" + yyFile.kind));
			gmxFile.addChild(new SfGmx("uncompress", yyFile.uncompress ? "-1" : "0"));
			//
			var gmxCopyTos = new SfGmx("ConfigOptions");
			var gmxCopyTo = new SfGmx("Config");
			gmxCopyTo.set("name", "Default");
			gmxCopyTo.addChild(new SfGmx("CopyToMask", "9223372036854775807"));
			gmxCopyTos.addChild(gmxCopyTo);
			gmxFile.addChild(gmxCopyTos);
			//
			var gmxProxies = new SfGmx("ProxyFiles");
			gmxFile.addChild(gmxProxies);
			//
			var gmxFuncs = new SfGmx("functions");
			for (yyFunc in yyFile.functions) {
				var gmxFunc = new SfGmx("function");
				gmxFunc.addChild(new SfGmx("name", yyFunc.name));
				gmxFunc.addChild(new SfGmx("externalName", yyFunc.externalName));
				gmxFunc.addChild(new SfGmx("kind", "" + yyFunc.kind));
				gmxFunc.addChild(new SfGmx("help", yyFunc.help));
				gmxFunc.addChild(new SfGmx("returnType", "" + yyFunc.returnType));
				gmxFunc.addChild(new SfGmx("argCount", "" + yyFunc.args.length));
				var gmxArgs = new SfGmx("args");
				for (yyArg in yyFunc.args) gmxArgs.addChild(new SfGmx("arg", "" + yyArg));
				gmxFunc.addChild(gmxArgs);
				gmxFuncs.addChild(gmxFunc);
			}
			gmxFile.addChild(gmxFuncs);
			//
			var gmxMacros = new SfGmx("constants");
			for (yyMacro in yyFile.constants) {
				var gmxMacro = new SfGmx("constant");
				gmxMacro.addChild(new SfGmx("name", yyMacro.constantName));
				gmxMacro.addChild(new SfGmx("value", yyMacro.value));
				gmxMacro.addChild(new SfGmx("hidden", yyMacro.hidden ? "-1" : "0"));
				gmxMacros.addChild(gmxMacro);
			}
			gmxFile.addChild(gmxMacros);
			//
			gmxFiles.addChild(gmxFile);
		}
		Sys.println("OK!");
		File.saveContent(args[1], gmx.toGmxString());
	}
	
}

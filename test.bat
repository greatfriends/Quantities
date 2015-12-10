@echo off
Packages\xunit.runner.console.2.1.0\tools\xunit.console ^
	GF.Quantities.Facts\bin\Debug\GF.Quantities.Facts.dll ^
	-parallel all ^
	-html Result.html  
@echo on 
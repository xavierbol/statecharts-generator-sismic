package be.ac.umons.bol.generator.sismic

class Utils {
	static def translateTypeInPythonType(String type) {
		switch (type) {
			case "boolean":
				return "bool"
			case "integer":
				return "int"
			case "real":
				return "float"
			case "string":
				return "str"
			case "void",
			case null:
				return "None"
			default:
				throw new Exception("Error, this type : " + type + " doesn't exist in Yakindu, impossible to translate for Sismic library...")
		}
	}	
}
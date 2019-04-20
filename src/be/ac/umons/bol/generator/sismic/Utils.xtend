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
			case "void":
				return "None"
			default:
				throw new Exception("Error, le type " + type + " n'existe pas en Yakindu, impossible de le traduire en Python")
		}
	}	
}
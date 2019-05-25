package be.ac.umons.bol.generator.sismic

abstract class Utils {
	private static String[] binaryOperators = #["«=", "»=", "&=", "^=", "|="]
	
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
	
	static def searchBinaryOperator(String specification) {
		for (binaryOperator : binaryOperators) {
			if (specification.contains(binaryOperator)) {
				throw new Exception("Impossible to convert the binary operators (" + binaryOperator + ") ...")
			}
		}
	}
}
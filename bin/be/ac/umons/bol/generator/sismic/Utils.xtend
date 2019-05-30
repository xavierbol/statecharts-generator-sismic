package be.ac.umons.bol.generator.sismic

abstract class Utils {
	static String[] binaryOperators = #["«=", "»=", "&=", "^=", "|="]
	
	/**
	 * translate type defined in the language of Yakindu Statechart Tools for its statechart into suitable type for Python.
	 * 
	 * @param type : the type use in the statechart in Yakindu
	 * 
	 * @return the suitable type for Python
	 */
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
	
	/**
	 * Search if the string contains binary operators
	 * If yes, then return exception because it's not use in Sismic.
	 * 
	 * @param specification : the string to check if it doesn't contains any binary operators
	 */
	static def searchBinaryOperator(String specification) {
		for (binaryOperator : binaryOperators) {
			if (specification.contains(binaryOperator)) {
				throw new Exception("Impossible to convert the binary operators (" + binaryOperator + ") ...")
			}
		}
	}
}
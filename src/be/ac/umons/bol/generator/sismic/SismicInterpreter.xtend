package be.ac.umons.bol.generator.sismic

import org.yakindu.sct.model.sgraph.Statechart
import be.ac.umons.bol.generator.sismic.specification.SpecificationRoot
import java.util.ArrayList

/**
 * Question :
 * 	- Pour ajouter les fonctions dans le context du statechart, dans le dictionnaire context, doit faire des appels aux fonctions
 * comme par exemple myfunc() ou bien myfunc suffit ?
 * 	- Est il mieux de définir une classe et mettant les variables et les opérations dans le fichier python au lieu de définir les variables
 * dans le preamble du fichier yaml et définir les functions dans le fichier python.
 */
abstract class SismicInterpreter {
	static def content(Statechart sc, SpecificationRoot specificationRoot) '''
		from sismic.io import import_from_yaml
		from sismic.interpreter import Interpreter
		from sismic.model import MacroStep
		
		«IF specificationRoot !== null && specificationRoot.operations !== null && !specificationRoot.operations.empty»
			«FOR operation : specificationRoot.operations»
				«operation»
					...
				
				
			«ENDFOR»
			context = «makeContext(specificationRoot.context)»
		«ELSE»
			context = {}
		«ENDIF»
		
		def set_up() -> Interpreter:
		    # Load statechart from yaml file
		    «sc.name» = import_from_yaml(filepath='«sc.name».yaml')
		
		    context = {"elapsed_time": 0}
		
		    # Create an interpreter for this statechart
		    return Interpreter(«sc.name», initial_context=context)
		
		
		def display_attributes(step: MacroStep) -> None:
		    for attribute in [
		        "event",
		        "transitions",
		        "entered_states",
		        "exited_states",
		        "sent_events",
		    ]:
		        print("{}: {}".format(attribute, getattr(step, attribute)))
		
		
		def next_step(interpreter: Interpreter) -> MacroStep:
		    print("Before:", interpreter.configuration)
		
		    step = interpreter.execute_once()
		
		    print("After:", interpreter.configuration)
		    return step
		
		if __name__ == "__main__":
		    interpreter = set_up()
		    step = next_step(interpreter)
		    display_attributes(step)
	'''
	
	static private def makeContext(ArrayList<String> context) '''
		{
			«FOR name : context»
				"«name»": «name»,
			«ENDFOR»
		}
	'''
}
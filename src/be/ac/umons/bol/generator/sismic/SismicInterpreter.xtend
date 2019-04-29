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
class SismicInterpreter {
	static public def content(Statechart sc, SpecificationRoot specificationRoot) '''
		from sismic.io import import_from_yaml
		from sismic.interpreter import Interpreter
		
		# Load statechart from yaml file
		«sc.name» = import_from_yaml(filepath='«sc.name».yaml')
		
		«IF specificationRoot !== null && specificationRoot.operations !== null && !specificationRoot.operations.empty»
			«FOR operation : specificationRoot.operations»
				«operation»
					...
				
				
			«ENDFOR»
			context = «makeContext(specificationRoot.context)»
		«ELSE»
			context = {}
		«ENDIF»
		
		# Create an interpreter for this statechart
		interpreter = Interpreter(elevator, initial_context=context)
		
		print('Before:', interpreter.configuration)
		
		step = interpreter.execute_once()
		
		print('After:', interpreter.configuration)
		
		for attribute in ['event', 'transitions', 'entered_states', 'exited_states', 'sent_events']:
		    print('{}: {}'.format(attribute, getattr(step, attribute)))
	'''
	
	static private def makeContext(ArrayList<String> context) '''
		{
			«FOR name : context»
				"«name»": «name»,
			«ENDFOR»
		}
	'''
}
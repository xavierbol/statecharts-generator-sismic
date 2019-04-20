package be.ac.umons.bol.generator.sismic;

import static be.ac.umons.bol.generator.sismic.IFeatureConstants.LIBRARY_NAME;
import static be.ac.umons.bol.generator.sismic.IFeatureConstants.MY_PARAMETER;

import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.emf.ecore.EObject;
import org.yakindu.sct.generator.core.library.AbstractDefaultFeatureValueProvider;
import org.yakindu.sct.model.sgen.FeatureParameterValue;
import org.yakindu.sct.model.sgen.FeatureType;
import org.yakindu.sct.model.sgen.FeatureTypeLibrary;
	
/**
 * Default value provider for SismicGenerator feature library
 */
public class SismicGeneratorDefaultValueProvider extends AbstractDefaultFeatureValueProvider {


	public boolean isProviderFor(FeatureTypeLibrary library) {
		return library.getName().equals(LIBRARY_NAME);
	}

	@Override
	protected void setDefaultValue(FeatureType type, FeatureParameterValue parameterValue, EObject context) {
		String parameterName = parameterValue.getParameter().getName();
		if (MY_PARAMETER.equals(parameterName)) {
			parameterValue.setValue("default value");
		}
	}

	public IStatus validateParameterValue(FeatureParameterValue parameterValue) {
		String parameterName = parameterValue.getParameter().getName();
		// TODO implement validation
		// return error("Illegal parameter value");
		return Status.OK_STATUS;
	}
}

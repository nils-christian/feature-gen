package de.rhocas.featuregen.ap

import org.eclipse.xtend.lib.macro.Active
import java.lang.annotation.Retention
import java.lang.annotation.Target

@Target(TYPE)
@Retention(CLASS)
@Active(FeatureIDEVariantProcessor)
annotation FeatureIDEVariant {
	
	/**
	 * The path to a variant configuration file from the {@code FeatureIDE} containing a set of features. The file path is relative to the annotated class.
	 * If the file path starts with a slash ({@code /}), the file path is absolute to the project source folder. If this value is not given, it is assumed
	 * that the configuration model is contained in an xml file next to the annotated class with the same name as the annotated class. Please note: Due to 
	 * restrictions of the active annotations, the file <b>must</b> be contained in the same project and the same source folder as the annotated class.
	 * 
	 * @since 1.0.0
	 */
	String value = ''
	
	/**
	 * The name of the variant. If this is not specified, the class name will be used instead.
	 * 
	 * @since 1.0.0
	 */
	String name = ''
	
	/**
	 * The prefix prepended to each generated feature.
	 * 
	 * @since 1.0.0
	 */
	String prefix = ''
	
	/**
	 * The suffix appended to each generated feature. This is set to {@code _FEATURE} by default.
	 * 
	 * @since 1.0.0
	 */
	String suffix = '_FEATURE'
	
	/**
	 * The package in which the features are contained. If this is empty, the package of the annotated class is used instead.
	 * 
	 * @since 1.0.0
	 */
	String featuresPackage = ''
	
}
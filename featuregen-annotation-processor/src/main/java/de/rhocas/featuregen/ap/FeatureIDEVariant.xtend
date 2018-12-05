package de.rhocas.featuregen.ap

import org.eclipse.xtend.lib.macro.Active
import java.lang.annotation.Retention
import java.lang.annotation.Target

@Target(TYPE)
@Retention(CLASS)
@Active(FeatureIDEVariantProcessor)
annotation FeatureIDEVariant {
	
	/**
	 * The path to a variant configuration file from the {@code FeatureIDE} containing a set of features. The file path is usually relative to the annotated
	 * class. If the file path starts with a slash ({@code /}), the file path is assumed to be relative to the project source folder. If this value is not
	 * given at all, it is assumed that the configuration model is contained in an xml file next to the annotated class with the same name as the annotated
	 * class.<br/>
	 * <br/>
	 * Please note: Due to restrictions of the active annotations, the file <b>must</b> be contained in the same project and the same source folder
	 * as the annotated class. Otherwise a build with various build tools might fail.
	 * 
	 * @since 1.0.0
	 */
	String value = ''
	
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
	 * The class which is annotated with {@link FeatureIDEFeatures}.
	 * 
	 * @since 1.0.0
	 */
	Class<?> featuresClass
	
}
package de.rhocas.featuregen.ap

import java.lang.annotation.Retention
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active

@Target(TYPE)
@Retention(CLASS)
@Active(FeatureIDEFeaturesProcessor)
annotation FeatureIDEFeatures {
 	
 	/**
	 * The path to a feature model file from the {@code FeatureIDE} containing the available features. The file path is relative to the annotated class.
	 * If the file path starts with a slash ({@code /}), the file path is absolute to the project source folder. If this value is not given, it is
	 * assumed that the feature model is contained in a file {@code model.xml} next to the annotated class. Please note: Due to restrictions of the 
	 * active annotations, the file <b>must</b> be contained in the same project and the same source folder as the annotated class.
	 * 
	 * @since 1.0.0
	 */
	String value = ''
	
	/**
	 * This prefix is prepended to each feature.
	 * 
	 * @since 1.0.0
	 */
	String prefix = ''
	
	/**
	 * This suffix is appended to each feature. This is set to {@code _FEATURE} by default.
	 * 
	 * @since 1.0.0
	 */
	String suffix = '_FEATURE'
 	
}
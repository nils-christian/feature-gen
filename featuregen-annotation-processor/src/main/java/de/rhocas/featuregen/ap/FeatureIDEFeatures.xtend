package de.rhocas.featuregen.ap

import java.lang.annotation.Retention
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active

@Target(TYPE)
@Retention(CLASS)
@Active(FeatureIDEFeaturesProcessor)
annotation FeatureIDEFeatures {
 	
}
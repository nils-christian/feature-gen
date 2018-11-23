package de.rhocas.featuregen.ap

import org.eclipse.xtend.lib.macro.Active
import java.lang.annotation.Retention
import java.lang.annotation.Target

@Target(TYPE)
@Retention(CLASS)
@Active(FeatureIDEVariantProcessor)
annotation FeatureIDEVariant {
	
}
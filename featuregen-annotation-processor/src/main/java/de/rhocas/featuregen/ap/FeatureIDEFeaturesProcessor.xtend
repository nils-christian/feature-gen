package de.rhocas.featuregen.ap

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext

class FeatureIDEFeaturesProcessor extends AbstractClassProcessor {
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		registerFeatureCheckService()
		registerSelectedFeatures()
		registerFeature()
	}
	
	private def registerFeatureCheckService() {
	}
	
	private def registerSelectedFeatures() {
	}
	
	private def registerFeature() {
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		transformFeatureCheckService()
		transformSelectedFeatures()
		transformFeature()
	}
	
	private def transformFeatureCheckService() {
	}
	
	private def transformSelectedFeatures() {
	}
	
	private def transformFeature() {
	}
	
}
[![Build Status](https://travis-ci.org/nils-christian/feature-gen.svg?branch=master)](https://travis-ci.org/nils-christian/feature-gen)

# feature-gen
feature-gen is a small open-source framework that lets you generate typesafe feature checks from FeatureIDE models

## How do I use it?
In order to use feature-gen in your project, simply add the Maven dependency to your pom.xml. The library requires Java 8 and Xtend 2.14 or newer.

	<dependency>
		<groupId>de.rhocas.featuregen</groupId>
		<artifactId>featuregen-annotation-processor</artifactId>
		<version>1.0.0-SNAPSHOT</version>
	</dependency>
  
Once you have the dependency in your classpath, you can add classes with the annotations *FeatureIDEFeatures* and *FeatureIDEVariant* to your project. Both classes use Xtend's active annotations mechanism to generate the required classes and enums to check features from your feature model.

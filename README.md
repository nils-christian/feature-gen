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

In its simplest form, you have your feature model in a file named *model.xml* next to your annotated class.

	@FeatureIDEFeatures
	class Features {   
	}
	
Your annotated variant class has to reference the feature class. In the following case it is assumed that the variant configuration is in a file named *Variant1.xml* next to the annotated class.

	@FeatureIDEVariant(featuresClass = Features)
	class Variant1 { 
	}
	
Now feature-gen generates everything to use the feature model in your application. Assuming your root feature is named *Root*, you can do the following:

	RootFeatureCheckService featureCheckService = RootFeatureCheckService.of( Variant1.class );

	if ( featureCheckService.isFeatureActive( RootFeature.MY_FEATURE ) ) {
	   ...
	}

## License

feature-gen is licensed under the MIT-License. The complete license text can be found in the provided file LICENSE.

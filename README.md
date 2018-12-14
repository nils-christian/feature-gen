[![Build Status](https://travis-ci.org/nils-christian/feature-gen.svg?branch=master)](https://travis-ci.org/nils-christian/feature-gen)

# feature-gen
feature-gen is a small open-source framework that lets you generate typesafe feature checks from FeatureIDE models

## How do I use it?
You can generate the features and variants either with the standalone generator or with the Xtend based active annotations. The standalone generator requires Java 8 and the annotation processor requires additionaly Xtend 2.14 or newer. 

The Java API for both approaches is the same. Assuming your root feature is named *Root*, you can do the following:

	RootFeatureCheckService featureCheckService = RootFeatureCheckService.of( Variant1.class );

	if ( featureCheckService.isFeatureActive( RootFeature.MY_FEATURE ) ) {
	   ...
	}
	
### Xtend Active Annotation

A simple example for the active annotations can be found [here](https://github.com/nils-christian/feature-gen-examples/tree/master/featuregen-examples-annotation-processor).

In order to use the active annotations from feature-gen in your project, you need to add the Maven dependencies to your project.

	<dependency>
		<groupId>de.rhocas.featuregen</groupId>
		<artifactId>featuregen-annotation-processor</artifactId>
		<version>2.0.0</version>
	</dependency>
	<dependency>
		<groupId>de.rhocas.featuregen</groupId>
		<artifactId>featuregen-lib</artifactId>
		<version>2.0.0</version>
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
	
Now feature-gen generates everything to use the feature model in your application.

### Standalone Generator

A simple example for the generator can be found [here](https://github.com/nils-christian/feature-gen-examples/tree/master/featuregen-examples-generator).

In order to use the standalone generator from feature-gen in your project, you need to add the Maven dependencies to your project.

	<dependency>
		<groupId>de.rhocas.featuregen</groupId>
		<artifactId>featuregen-generator</artifactId>
		<version>2.0.0</version>
	</dependency>
	<dependency>
		<groupId>de.rhocas.featuregen</groupId>
		<artifactId>featuregen-lib</artifactId>
		<version>2.0.0</version>
	</dependency>
	
Now you can call the classes *FeatureIDEFeaturesGenerator* and *FeatureIDEVariantGenerator* as Java applications and generate the features and variants from your models. 

The *FeatureIDEFeaturesGenerator* requires at least three parameters: The path to the FeatureIDE feature model file, the path to the output folder, and the package name of the newly generated classes. Optionally you can also provide the prefix and suffix which are appended to each feature.

The *FeatureIDEVariantGenerator* requires at least six parameters: The path to the FeatureIDE configuration model file, the path to the feature model file, the path to the output folder, the package name of the newly generated variant, the simple class name of the new variant, and the package name of the features. Optionally you can also provide the prefix and suffix which are appended to each feature.

An easy way to include the generator in your IDE is to use the *exec-maven-plugin*. Please consult the Wiki for this.

Once you called the generators, feature-gen generates everything to use the feature model in your application. 
	
## License

feature-gen is licensed under the MIT-License. The complete license text can be found in the provided file LICENSE.

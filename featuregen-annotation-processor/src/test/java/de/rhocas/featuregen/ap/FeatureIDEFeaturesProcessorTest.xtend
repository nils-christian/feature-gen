package de.rhocas.featuregen.ap

import org.junit.Test

import static org.hamcrest.collection.IsEmptyCollection.empty
import static org.hamcrest.collection.IsCollectionWithSize.hasSize
import static org.hamcrest.core.Is.is
import static org.junit.Assert.assertThat
import org.eclipse.xtext.diagnostics.Severity

class FeatureIDEFeaturesProcessorTest {

	extension WorkspaceAwareXtendCompilerTester = WorkspaceAwareXtendCompilerTester.newWorkspaceAwareXtendCompilerTester(FeatureIDEFeatures.classLoader)

	@Test
	def void simpleCaseShouldBeGeneratedCorrectly() {
		val workspaceContent = #{'/myProject/src/model.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<and mandatory="true" name="Root">
						<feature name="F1"/>
					</and>
			    </struct>
			</featureModel>
		'''}

		assertCompilesTo(workspaceContent, '''
			package test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»
			class Features {   
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/test/Features.java
			
			package test;
			
			import de.rhocas.featuregen.ap.FeatureIDEFeatures;
			
			@FeatureIDEFeatures
			@SuppressWarnings("all")
			public class Features {
			}
			
			File 2 : /myProject/xtend-gen/test/RootFeature.java
			
			package test;
			
			/**
			 * This enumeration contains all available features.<br/>
			 * <br/>
			 * This enumeration is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public enum RootFeature {
			  ROOT_FEATURE,
			  
			  F1_FEATURE;
			}
			
			File 3 : /myProject/xtend-gen/test/RootFeatureCheckService.java
			
			package test;
			
			import java.util.Arrays;
			import java.util.Collections;
			import java.util.EnumSet;
			import java.util.List;
			import java.util.Objects;
			import java.util.Set;
			import test.RootFeature;
			import test.RootSelectedFeatures;
			import test.RootVariant;
			
			/**
			 * This service allows to set the currently active variant and to check which features are currently active.<br/>
			 * <br/>
			 * Note that this class is conditionally thread safe. This means that it is possible to concurrently set the 
			 * variant and check the features, but it is possible that a check for a feature returns {@code false} between
			 * the switching from one variant to another even if both variants contain said feature. Add additional
			 * synchronization if switching the variant must be an atomic operation.<br/>
			 * <br/>
			 * This service is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public final class RootFeatureCheckService {
			  private final Set activeFeatures = Collections.synchronizedSet( EnumSet.noneOf( RootFeature.class ) );
			  
			  /**
			   * Checks whether the given feature is currently active or not.
			   * 
			   * @param feature
			   * 	The feature to check. Must not be {@code null}.
			   * 	
			   * @return true if and only if the given feature is active.
			   * 
			   * @throws NullPointerException
			   * 	If the given feature is {@code null}.
			   * 
			   */
			  public boolean isFeatureActive(final RootFeature feature) {
			    Objects.requireNonNull( feature, "The feature must not be null." );
			    
			    return activeFeatures.contains( feature );
			  }
			  
			  /**
			   * Sets the currently active variant.
			   * 
			   * @param variant
			   * 	The new variant. Must not be {@code null} and must be annotated with {@link RootSelectedFeatures}.
			   * 	
			   * @throws NullPointerException
			   * 	If the given variant is {@code null} or not annotated with {@link RootSelectedFeatures}.
			   * 
			   */
			  public void setActiveVariant(final Class<? extends RootVariant> variant) {
			    Objects.requireNonNull( variant, "The variant must not be null." );
			    
			    final RootSelectedFeatures selectedFeaturesAnnotation = variant.getAnnotation( RootSelectedFeatures.class );
			    Objects.requireNonNull( selectedFeaturesAnnotation, "The variant must be annotated with RootSelectedFeatures." );
			    final List<RootFeature> selectedFeatures = Arrays.asList( selectedFeaturesAnnotation.value( ) );
			    
			    activeFeatures.clear( );
			    activeFeatures.addAll( selectedFeatures );
			  }
			}
			
			File 4 : /myProject/xtend-gen/test/RootSelectedFeatures.java
			
			package test;
			
			import java.lang.annotation.ElementType;
			import java.lang.annotation.Retention;
			import java.lang.annotation.RetentionPolicy;
			import java.lang.annotation.Target;
			import test.RootFeature;
			
			/**
			 * This annotation is used to mark which features the annotated variant provides.<br/>
			 * <br/>
			 * This annotation is generated.
			 * 
			 */
			@Retention(value = RetentionPolicy.RUNTIME)
			@Target(value = ElementType.TYPE)
			public @interface RootSelectedFeatures {
			  /**
			   * The selected features.
			   */
			  public RootFeature[] value();
			}
			
			File 5 : /myProject/xtend-gen/test/RootVariant.java
			
			package test;
			
			/**
			 * This is a marker interface for all variants.<br/>
			 * <br/>
			 * This interface is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public interface RootVariant {
			}
			
		''')
	}
	
	@Test
	def void simpleCaseWithPrefixAndSuffixShouldBeGeneratedCorrectly() {
		val workspaceContent = #{'/myProject/src/model.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<and mandatory="true" name="Root">
						<feature name="F1"/>
					</and>
			    </struct>
			</featureModel>
		'''}

		assertCompilesTo(workspaceContent, '''
			package test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»(prefix='prefix_', suffix='_suffix')
			class Features {   
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/test/Features.java
			
			package test;
			
			import de.rhocas.featuregen.ap.FeatureIDEFeatures;
			
			@FeatureIDEFeatures(prefix = "prefix_", suffix = "_suffix")
			@SuppressWarnings("all")
			public class Features {
			}
			
			File 2 : /myProject/xtend-gen/test/RootFeature.java
			
			package test;
			
			/**
			 * This enumeration contains all available features.<br/>
			 * <br/>
			 * This enumeration is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public enum RootFeature {
			  PREFIX_ROOT_SUFFIX,
			  
			  PREFIX_F1_SUFFIX;
			}
			
			File 3 : /myProject/xtend-gen/test/RootFeatureCheckService.java
			
			package test;
			
			import java.util.Arrays;
			import java.util.Collections;
			import java.util.EnumSet;
			import java.util.List;
			import java.util.Objects;
			import java.util.Set;
			import test.RootFeature;
			import test.RootSelectedFeatures;
			import test.RootVariant;
			
			/**
			 * This service allows to set the currently active variant and to check which features are currently active.<br/>
			 * <br/>
			 * Note that this class is conditionally thread safe. This means that it is possible to concurrently set the 
			 * variant and check the features, but it is possible that a check for a feature returns {@code false} between
			 * the switching from one variant to another even if both variants contain said feature. Add additional
			 * synchronization if switching the variant must be an atomic operation.<br/>
			 * <br/>
			 * This service is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public final class RootFeatureCheckService {
			  private final Set activeFeatures = Collections.synchronizedSet( EnumSet.noneOf( RootFeature.class ) );
			  
			  /**
			   * Checks whether the given feature is currently active or not.
			   * 
			   * @param feature
			   * 	The feature to check. Must not be {@code null}.
			   * 	
			   * @return true if and only if the given feature is active.
			   * 
			   * @throws NullPointerException
			   * 	If the given feature is {@code null}.
			   * 
			   */
			  public boolean isFeatureActive(final RootFeature feature) {
			    Objects.requireNonNull( feature, "The feature must not be null." );
			    
			    return activeFeatures.contains( feature );
			  }
			  
			  /**
			   * Sets the currently active variant.
			   * 
			   * @param variant
			   * 	The new variant. Must not be {@code null} and must be annotated with {@link RootSelectedFeatures}.
			   * 	
			   * @throws NullPointerException
			   * 	If the given variant is {@code null} or not annotated with {@link RootSelectedFeatures}.
			   * 
			   */
			  public void setActiveVariant(final Class<? extends RootVariant> variant) {
			    Objects.requireNonNull( variant, "The variant must not be null." );
			    
			    final RootSelectedFeatures selectedFeaturesAnnotation = variant.getAnnotation( RootSelectedFeatures.class );
			    Objects.requireNonNull( selectedFeaturesAnnotation, "The variant must be annotated with RootSelectedFeatures." );
			    final List<RootFeature> selectedFeatures = Arrays.asList( selectedFeaturesAnnotation.value( ) );
			    
			    activeFeatures.clear( );
			    activeFeatures.addAll( selectedFeatures );
			  }
			}
			
			File 4 : /myProject/xtend-gen/test/RootSelectedFeatures.java
			
			package test;
			
			import java.lang.annotation.ElementType;
			import java.lang.annotation.Retention;
			import java.lang.annotation.RetentionPolicy;
			import java.lang.annotation.Target;
			import test.RootFeature;
			
			/**
			 * This annotation is used to mark which features the annotated variant provides.<br/>
			 * <br/>
			 * This annotation is generated.
			 * 
			 */
			@Retention(value = RetentionPolicy.RUNTIME)
			@Target(value = ElementType.TYPE)
			public @interface RootSelectedFeatures {
			  /**
			   * The selected features.
			   */
			  public RootFeature[] value();
			}
			
			File 5 : /myProject/xtend-gen/test/RootVariant.java
			
			package test;
			
			/**
			 * This is a marker interface for all variants.<br/>
			 * <br/>
			 * This interface is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public interface RootVariant {
			}
			
		''')
	}
	
	@Test
	def void missingFileShouldResultInError() {
		compile(#{}, '''
			package test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»
			class Features {   
			}
		''', [result |
			assertThat(result.errorsAndWarnings, hasSize(1))
			
			val error = result.errorsAndWarnings.head
			assertThat(error.severity, is(Severity.ERROR))
			assertThat(error.message, is('The model file could not be found (Assumed path was: \'/myProject/src/model.xml\').'))
		])
	}
	
	@Test
	def void filePathWithoutSlashShouldBeRelativeToClass() {
		val workspaceContent = #{'/myProject/src/path/file.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<and mandatory="true" name="Root">
						<feature name="F1"/>
					</and>
			    </struct>
			</featureModel>
		'''}
		
		compile(workspaceContent, '''
			package test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»('path/file.xml')
			class Features {   
			}
		''', [result |
			assertThat(result.errorsAndWarnings, is(empty()))
		])
	}
	
	@Test
	def void filePathWithSlashShouldBeRelativeToSourceFolder() {
		val workspaceContent = #{'/myProject/path/file.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<and mandatory="true" name="Root">
						<feature name="F1"/>
					</and>
			    </struct>
			</featureModel>
		'''}
		
		compile(workspaceContent, '''
			package test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»('/path/file.xml')
			class Features {   
			}
		''', [result |
			assertThat(result.errorsAndWarnings, is(empty()))
		])
	}
	
}

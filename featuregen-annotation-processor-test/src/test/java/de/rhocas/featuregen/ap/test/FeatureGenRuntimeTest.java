package de.rhocas.featuregen.ap.test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;

import de.rhocas.featuregen.ap.test.feature.FeatureGenTestFeature;
import de.rhocas.featuregen.ap.test.feature.FeatureGenTestFeatureCheckService;
import de.rhocas.featuregen.ap.test.variant.Variant1;
import de.rhocas.featuregen.ap.test.variant.Variant2;

public class FeatureGenRuntimeTest {

	@Rule
	public ExpectedException expectedException = ExpectedException.none();
	
	@Test
	public void featureCheckWithoutVariant() {
		final FeatureGenTestFeatureCheckService featureCheckService = new FeatureGenTestFeatureCheckService();
		for (final FeatureGenTestFeature feature : FeatureGenTestFeature.values()) {
			final boolean featureActive = featureCheckService.isFeatureActive(feature);
			assertFalse(featureActive);
		}
	}

	@Test
	public void featureCheckWithVariant() {
		final FeatureGenTestFeatureCheckService featureCheckService = new FeatureGenTestFeatureCheckService();
		featureCheckService.setActiveVariant(Variant1.class);

		assertTrue(featureCheckService.isFeatureActive(FeatureGenTestFeature.FEATUREGENTEST_FEATURE));
		assertTrue(featureCheckService.isFeatureActive(FeatureGenTestFeature.F2_FEATURE));
		
		assertFalse(featureCheckService.isFeatureActive(FeatureGenTestFeature.F51_FEATURE));
	}
	
	@Test
	public void featureCheckWithVariantChange() {
		final FeatureGenTestFeatureCheckService featureCheckService = new FeatureGenTestFeatureCheckService();
		featureCheckService.setActiveVariant(Variant1.class);
		featureCheckService.setActiveVariant(Variant2.class);

		assertTrue(featureCheckService.isFeatureActive(FeatureGenTestFeature.FEATUREGENTEST_FEATURE));
		assertTrue(featureCheckService.isFeatureActive(FeatureGenTestFeature.F51_FEATURE));
	}
	
	@Test
	public void featureCheckWithNullVariant() {
		final FeatureGenTestFeatureCheckService featureCheckService = new FeatureGenTestFeatureCheckService();
		
		expectedException.expect(NullPointerException.class);
		expectedException.expectMessage("The variant must not be null.");
		featureCheckService.setActiveVariant(null);
	}
	
	@Test
	public void featureCheckWithNullFeature() {
		final FeatureGenTestFeatureCheckService featureCheckService = new FeatureGenTestFeatureCheckService();
		
		expectedException.expect(NullPointerException.class);
		expectedException.expectMessage("The feature must not be null.");
		featureCheckService.isFeatureActive(null);
	}

}

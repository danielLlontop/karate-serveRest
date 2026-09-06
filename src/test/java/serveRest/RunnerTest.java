package serveRest;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;

class RunnerTest {

    @Test
    void testParallel() {
        int threadCount = System.getProperty("threads") != null
                ? Integer.parseInt(System.getProperty("threads"))
                : 2;

        Results results = Runner.path("classpath:serveRest/features")
                .tags("~@ignore")
                .outputCucumberJson(true)
                .parallel(threadCount);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

}

package serveRest.features.carts;

import com.intuit.karate.junit5.Karate;

class CartsRunner {
    
    @Karate.Test
    Karate testCarts() {
        return Karate.run("carts").relativeTo(getClass());
    }    

}

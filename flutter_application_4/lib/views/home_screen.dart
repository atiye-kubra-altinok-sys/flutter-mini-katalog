import 'package:flutter/material.dart';
import 'package:flutter_application_4/compenents/product_card.dart';
import 'package:flutter_application_4/model/product_model.dart';
import 'package:flutter_application_4/services/api_service.dart';
import 'package:flutter_application_4/views/cart_screen.dart';
import 'package:flutter_application_4/views/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  String errorMessage = "";
  List<Data> allProducts = [];
  ApiService apiService = ApiService();
  final Set<int> cartIds = {};
  String searchQuery = "";

  @override
  void initState() {
    loadProducts();
    super.initState();
  }

  Future<void> loadProducts() async {
    try {
      setState(() {
        isLoading = true;
      });

      ProductModel resData = await apiService.fetchProducts();

      setState(() {
        allProducts = resData.data ?? [];
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load products.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = allProducts.where((product) {
      final name = product.name ?? "";
      return name.toUpperCase().contains(searchQuery.toUpperCase());
    }).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Explore Devices",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartScreen(
                            products: allProducts,
                            cartIds: cartIds,
                          ),
                        ),
                      );
                    },
                    iconSize: 34,
                    icon: Icon(Icons.shopping_bag_outlined),
                  ),
                ],
              ),
              SizedBox(height: 9), //dikey boşluk verme
              Text(
                "Find your perfect device",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xfff5f5f5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText:
                        "Search products", //ilgili. textfield'ın arka plandaki yer tutucusunu gösteren text parametresidir.
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),

                    // YENİ EKLENEN KISIM: Arama kutusu doluysa X ikonunu göster
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                searchController
                                    .clear(); // TextField içindeki metni siler
                                searchQuery =
                                    ""; // Arama sorgusunu sıfırlayıp ekranı günceller
                              });
                            },
                          )
                        : null, // Arama kutusu boşsa ikonu gizle

                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 16),

              Container(
                width: double.infinity,
                height: 80.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(
                      "https://wantapi.com/assets/banner.png",
                    ),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              SizedBox(height: 16),

              if (isLoading) //burayı bir önceki derste operatorler ile yapmıştık
                Center(child: CircularProgressIndicator())
              else if (errorMessage != "")
                Center(child: Text(errorMessage))
              else
                Expanded(
                  child: GridView.builder(
                    itemCount: filteredProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                product: product,
                                cartIds: cartIds,
                              ),
                            ),
                          );
                        },
                        child: ProductCard(product: product),
                      );
                    },
                  ),
                ), //bir önceki ders listview yapısı kullanıldı
            ],
          ),
        ),
      ),
    );
  }
}

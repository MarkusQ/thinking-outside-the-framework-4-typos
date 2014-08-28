module Typo
    def self.cost(c1,c2)
        c1 == c2    ?                0 :
        !(c1 && c2) ?                1 :
        c1.downcase == c2.downcase ? 0 :
                                     1
    end
    def self.levenshtein(a,b,i,j)
        if [i,j].min == -1
            [i,j].max+1
        else
            [
                levenshtein(a,b,i-1,j  )+1,
                levenshtein(a,b,i,  j-1)+1,
                levenshtein(a,b,i-1,j-1)+cost(a[i],b[j])
            ].min
        end
    end

    def self.edit_distance(w1,w2)
        levenshtein(w1,w2,w1.length,w2.length)
    end

    def self.closest_words(w)
        dict = File.readlines("american-english").map(&:chomp)
        best_score = w.length+1
        best = []
        dict.each { |word|
            case edit_distance(w,word)
              when 0...best_score
                best_score = edit_distance(w,word)
                best = [word]
              when best_score
                best << word
              end
        }
        best
    end
end
    
File.read("testdata").split(/\W+/m).each { |w| p [w,Typo.closest_words(w)] }
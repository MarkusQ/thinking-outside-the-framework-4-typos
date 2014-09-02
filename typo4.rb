module Typo
    def self.levenshtein(s,t)
        return 0          if s.downcase == t.downcase
        return t.length   if s.length == 0
        return s.length   if t.length == 0

        v0 = (0..t.length).to_a

        (0...s.length).each { |i|
            v1 = v0.dup
            v1[0] = i + 1
            (0...t.length).each { |j|
                cost = (s[i].downcase == t[j].downcase) ? 0 : 1
                v1[j + 1] = [v1[j]+1, v0[j+1]+1, v0[j]+cost].min
            }
            v0 = v1
        }

        v0[t.length]
    end

    def self.edit_distance(w1,w2)
        levenshtein(w1,w2)
    end

    @dict = Hash.new { |h,k| h[k] = [] }
    File.readlines("american-english").map(&:chomp).each { |w| @dict[w.downcase] << w }
    def self.closest_words(w)
        return @dict[w.downcase] if @dict.keys.include?(w.downcase)
        best_score = w.length+1
        best = []
        @dict.each { |word,forms|
            if best_score >= word.length-w.length
                score = edit_distance(w,word)
                case score
                  when 0...best_score
                    best_score = score
                    best = forms.dup
                  when best_score
                    best |= forms
                  end
            end
        }
        best
    end
end

File.read("testdata").split(/\W+/m).each { |w| p [w,Typo.closest_words(w)] }
